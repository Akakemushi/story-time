require 'json'

class CreateNewStoryJob < ApplicationJob
  queue_as :default

  def perform(prompt, template, user_id, story_id, failed_tries = 0)
    template_instance = PromptTemplate.find(template)
    user = User.find(user_id)
    story = Story.find(story_id)

    first_response = OpenaiService.new(prompt).call
    segment_data = JSON.parse(first_response)

    if segment_data.key?("title") &&
       segment_data.key?("paragraphs") &&
       segment_data.key?("choices") &&
       segment_data["paragraphs"].kind_of?(Array) &&
       segment_data["paragraphs"].length >= 2 &&
       segment_data["choices"].kind_of?(Array) &&
       segment_data["choices"].length == 2

      prompt_segment = StorySegment.create!({story: story})
      first_segment = StorySegment.create!({story: story})
      story.title = segment_data["title"]
      story.system_prompt = prompt
      story.save!
      puts "MMMMMMMMMMMMMMMMMMMMMMMM New story successfully saved."

      puts "MMMMMMMMMMMMMMMMMMMMMMMM Attempting to save system prompt (aka segment 0)..."
      prompt_segment.order = 0
      prompt_segment.message = prompt
      prompt_segment.role = "system"
      prompt_segment.save!
      puts "MMMMMMMMMMMMMMMMMMMMMMMM System prompt (segment 0) successfully saved."

      picture_segment = CreateNewArtJob.perform_now({paragraphs: segment_data["paragraphs"].join(" "), segment: first_segment})
      puts "MMMMMMMMMMMMMMMMMMMMMMMM  Returned from CreateNewArtJob."

      puts "MMMMMMMMMMMMMMMMMMMMMMMM Attempting to save first story segment (aka segment 1)..."
      picture_segment.order = 1
      picture_segment.message = first_response
      picture_segment.role = "assistant"
      picture_segment.save!
      puts "MMMMMMMMMMMMMMMMMMMMMMMM First story segment (segment 1) successfully saved."

      StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.story_path(story) })
    else
      failed_tries += 1
      if failed_tries < 3
        puts "MMMMMMMMMMMMMMMMMMMMMMMM ChatGPT response was not in the correct format...(#{failed_tries} fails) requesting again... "
        self.class.perform_now(prompt, template, user_id, story_id, failed_tries)
      else
        puts "MMMMMMMMMMMMMMMMMMMMMMMM Doesn't look like ChatGPT likes this prompt... Giving up.  Try a different prompt."
        StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.new_story_path })
        story.destroy
      end
    end
  rescue OpenaiService::ApiError => e
    puts "MMMMMMMMMMMMMMMMMMMMMMMM OpenAI API error: #{e.message}"
    failed_tries += 1
    if failed_tries < 3
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Retrying... (attempt #{failed_tries})"
      self.class.perform_now(prompt, template, user_id, story_id, failed_tries)
    else
      puts "MMMMMMMMMMMMMMMMMMMMMMMM Giving up after #{failed_tries} failed attempts."
      story = Story.find(story_id)
      StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.new_story_path })
      story.destroy
    end
  rescue JSON::ParserError => e
    puts "MMMMMMMMMMMMMMMMMMMMMMMM Failed to parse JSON from ChatGPT: #{e.message}"
    failed_tries += 1
    if failed_tries < 3
      self.class.perform_now(prompt, template, user_id, story_id, failed_tries)
    else
      story = Story.find(story_id)
      StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.new_story_path })
      story.destroy
    end
  rescue Faraday::Error => e
    puts "MMMMMMMMMMMMMMMMMMMMMMMM HTTP error calling OpenAI: #{e.message}"
    story = Story.find(story_id)
    StoryChannel.broadcast_to(story, { action: 'redirect', path: Rails.application.routes.url_helpers.new_story_path })
    story.destroy
  end
end
