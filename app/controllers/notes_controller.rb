class NotesController < ApplicationController
  def edit
    @note = fetch_note
    authorize(@note)
  end

  def update
    @note = fetch_note
    authorize(@note)
    if @note.update(note_params)
      redirect_to(
        model_indicator_path(@note.model, @note.indicator),
        notice: 'Note was successfully updated.'
      )
    else
      flash.now[:alert] =
        'We could not update the note. Please check the inputs in red'
      render(:edit)
    end
  end

  private

  def fetch_note
    Note.find_or_create_by(params.permit(*%w[model_id indicator_id])).tap { |a| puts a.inspect }
  end

  def note_params
    params.require(:note).permit(Note.attribute_symbols_for_strong_params)
  end
end
