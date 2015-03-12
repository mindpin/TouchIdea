class ShareToWeibo
  def initialize(args={})
    @users_count_per_share = (ENV['USERS_COUNT_PER_SHARE'] || 10).to_i
    @mark = Rails.env.production? ? '@' : '!'
  end

  def post_statuses_for_vote_invite_users vote
    user = vote.user
    token = user.user_tokens.last
    return false if token.nil?
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash({:access_token=> token.token,:expires_at=> token.expires_at})
    @short_url = short_url client, vote
    short_title = vote.title.block(25)

    names = vote.invite_uids.map{ |uid| client.users.show_by_uid(uid).name }
    
    plus = 0
    while !names.blank?
      status = "【#{short_title}】 #{names.pop(@users_count_per_share).collect{|name| @mark + name}.join(' ')} 你们怎么看 #{@short_url}"
      times = 0
      begin
        client.statuses.update(status)
        p 'success share ' + status
        sleep 1
      rescue
        times = times + 1
        break if times > 2
        sleep 3
        retry
      end
    end
  end

  def user_invite_by_uids user, vote, uids
    token = user.user_tokens.last
    return false if token.nil?
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash({:access_token=> token.token,:expires_at=> token.expires_at})
    @short_url = short_url client, vote
    short_title = vote.title.block(25)

    names = uids.map{ |uid| client.users.show_by_uid(uid).name }
    
    plus = 0
    while !names.blank?
      status = "【#{short_title}】 #{names.pop(@users_count_per_share).collect{|name| @mark + name}.join(' ')} 你们怎么看 #{@short_url}"
      times = 0
      begin
        client.statuses.update(status)
        p 'success share ' + status
        sleep 1
      rescue
        times = times + 1
        break if times > 2
        sleep 3
        retry
      end
    end
  end

  def short_url client, vote
    url = "#{ENV['BASE_URL']}/#{vote.token}"
    client.short_url.shorten(url).urls.first.url_short
  end
end
