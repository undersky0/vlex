module FlashHelper
  def render_turbo_flash(flash_type = nil, message = nil)
    flash.now[flash_type] = message if message && flash_type
    turbo_stream.prepend("flash", partial: "shared/flash")
  end
end
