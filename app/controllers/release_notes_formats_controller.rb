class ReleaseNotesFormatsController < ApplicationController
  def new
    @format = ReleaseNotesFormat.new
  end

  def create
    @format = ReleaseNotesFormat.new(params[:release_notes_format])
    if @format.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to release_notes_formats_tab_path
    else
      render 'new'
    end
  end

  def edit
    @format = ReleaseNotesFormat.find(params[:id])
  end

  def update
    @format = ReleaseNotesFormat.find(params[:id])
    if @format.update_attributes(params[:release_notes_format])
      flash[:notice] = l(:notice_successful_update)
      redirect_to release_notes_formats_tab_path
    else
      render 'edit'
    end
  end

  def destroy
    @format = ReleaseNotesFormat.find(params[:id])
    @format.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to release_notes_formats_tab_path
  end
end
