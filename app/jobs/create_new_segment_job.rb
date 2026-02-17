require 'json'

class CreateNewSegmentJob < ApplicationJob  # this job will put together a running total of all chat messages and send it to the api to get back the next segment. It will then call create_art_prompt.
  queue_as :default

  def perform(input, failed_tries = 0)   #user_choice    story_id    root_segment_id
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Now entering CreateNewSegmentJob..."
    story = Story.find(input[:story_id])
    root_segment = StorySegment.find(input[:root_segment_id])
    root_segment_id = input[:root_segment_id]
    root_order = root_segment.order
    new_segment_hash = {story_id: input[:story_id]}
    big_bubba = []
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Fetching story segments for this story..."
    segments = StorySegment.where(story_id: story.id).sort_by(&:order)
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Assembling \"Big Bubba\"..."
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Bubba has #{segments.count} segments."
    segments.each_with_index do |segment, index|
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Looking at hash number #{index}..."
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Role is #{segment.role}"
      current_hash = {
        role: segment.role,
        content: segment.message
      }
      big_bubba << current_hash
    end # Big Bubba loop end tag
    user_hash = {
      role: "user",
      content: input[:user_choice].to_s
    }
    big_bubba << user_hash
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Big Bubba successfully created."
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Calling ChatGPT...."
    segment_message = OpenaiService.new(big_bubba).add_segment_call
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Response received from ChatGPT... parsing..."
    segment_data = JSON.parse(segment_message)
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Validating response format..."

    if segment_data.key?("paragraphs") && segment_data["paragraphs"].kind_of?(Array) && segment_data["paragraphs"].length >= 2
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Paragraphs are ok, checking for choices..."

      # Generate image for this segment (non-fatal if it fails)
      url = nil
      begin
        puts "MMMMMMMMMMMMMMMMMMMMMMMM Generating art prompt and DALL-E image..."
        img_prompt = OpenaiService.new(segment_data["paragraphs"].join(" ")).generate_art_prompt
        url = OpenaiService.generate_image(img_prompt)
        puts "MMMMMMMMMMMMMMMMMMMMMMMMMMMMM  Url below of the generated image below..."
        puts url
      rescue OpenaiService::ApiError, Faraday::Error => e
        puts "MMMMMMMMMMMMMMMMMMMMMMMM DALL-E image generation failed (non-fatal): #{e.message}"
        puts "MMMMMMMMMMMMMMMMMMMMMMMM Continuing without image..."
      end

      new_segment_hash[:message] = segment_message
      new_segment_hash[:role] = "assistant"
      new_segment_hash[:order] = root_order.to_i + 2
      new_segment_hash[:image] = url
      cache_id = "story_id#{story.id}:root_segment_id#{root_segment_id}:#{input[:user_choice]}"

      if segment_data.key?("choices") && segment_data["choices"].kind_of?(Array) && segment_data["choices"].length == 2
        puts "MMMMMMMMMMMMMMMMMMMMMMMM Choices are ok.  Story should continue."
      else
        puts "MMMMMMMMMMMMMMMMMMMMMMMM No choices found, this will be the last segment."
      end

      puts "MMMMMMMMMMMMMMMMMMMMMMMMMMMMM Writing data to Rails cache"
      Rails.cache.write(cache_id, new_segment_hash, expires_in: 1.hour)
      puts "MMMMMMMMMMMMMMMMMMMMMMMMMMMMM Broadcasting the end of job #{input[:user_choice]}"
      SegmentChannel.broadcast_to(root_segment, { action: 'segment_ready', user_choice: input[:user_choice], new_segment_hash: new_segment_hash.to_json, cache_id: cache_id})
    else
      failed_tries += 1
      if failed_tries < 3
        puts "Paragraphs are invalid... Asking ChatGPT to try again... (attempt #{failed_tries})"
        self.class.perform_now(input, failed_tries)
      else
        puts "MMMMMMMMMMMMMMMMMMMMMMMM Doesn't look like ChatGPT is cooperating... Giving up.  Maybe try later?"
        StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.story_path(story) })
        return
      end
    end
  rescue OpenaiService::ApiError => e
    puts "MMMMMMMMMMMMMMMMMMMMMMMM OpenAI API error: #{e.message}"
    failed_tries += 1
    if failed_tries < 3
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Retrying... (attempt #{failed_tries})"
      self.class.perform_now(input, failed_tries)
    else
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Giving up after #{failed_tries} failed attempts."
      story = Story.find(input[:story_id])
      StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.story_path(story) })
    end
  rescue JSON::ParserError => e
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Failed to parse JSON from ChatGPT: #{e.message}"
    failed_tries += 1
    if failed_tries < 3
      self.class.perform_now(input, failed_tries)
    else
      story = Story.find(input[:story_id])
      StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.story_path(story) })
    end
  rescue Faraday::Error => e
    puts "MMMMMMMMMMMMMMMMMMMMMMMM HTTP error calling OpenAI: #{e.message}"
    story = Story.find(input[:story_id])
    StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.story_path(story) })
  end
end
