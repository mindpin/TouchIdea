module ApplicationHelper
  # 头像
  def avatar(user)
    capture_haml {
      haml_tag 'div.-avatar-img' do
        haml_tag 'img', :src => user.avatar_url, :alt => user.nickname
      end
    }
  end
end
