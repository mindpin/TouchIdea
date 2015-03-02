class LayoutCell < Cell::Rails
  helper :application

  def navbar(option)
    @user = option[:user]
    render
  end

  def flash_messages(flash)
    @flash = flash
    render
  end
end