class FlashcardsController < ApplicationController
  def index
    @flashcards = current_user.flashcards
    @story = Story.find_by(id: params[:story_id])
    if @story
      @flashcards = @flashcards.where(story_segment: @story.story_segments)
    end
    @search_query = params[:search_query]
    
    @flashcards = @flashcards.search(@search_query) if @search_query.present?
    @story_segments = StorySegment.where(id: @flashcards.pluck(:story_segment_id))
    @stories = Story.where(id: @story_segments.pluck(:story_id))
  end

  def show
    @flashcard = Flashcard.find(params[:id])
  end

  def new
    @flashcard = Flashcard.new
  end

  def create
    # POST story_segments/114/flashcards?paragraph=2
    @story_segment = StorySegment.find(params[:story_segment_id])
    @flashcard = Flashcard.new(flashcard_params)
    @flashcard.story_segment = @story_segment
    @flashcard.user = current_user

    if @flashcard.save
      redirect_to story_segment_path(@flashcard.story_segment, paragraph: params[:paragraph])
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def flashcard_params
    params.require(:flashcard).permit(:excerpt, :answer)
  end
end
