# (c) goodprogrammer.ru
#
# Унаследовали контроллер регистраций от девайза, чтобы
# добавить проверку капчи перед созданием юзера
# https://github.com/plataformatec/devise/wiki/How-To:-Use-Recaptcha-with-Devise
class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]

  private
  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) {render :new}
    end
  end
end