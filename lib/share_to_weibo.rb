class ShareToWeibo
  def initialize(args={})
    
  end

  def post_statuses_for_vote_invite_users vote
    user = vote.user
    token = user.user_tokens.last
    return false if token.nil?
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash({:access_token=> token.token,:expires_at=> token.expires_at})
    names = vote.invite_uids.map{ |uid| client.users.show_by_uid(uid).name }

    short = short_url client, vote
    status = "【#{vote.title.block(25)}】 #{names.collect{|name| '@' + name}.join(' ')} 你们怎么看 #{short}"
    client.statuses.update(status)
  end

  def short_url client, vote
    url = "#{ENV['BASE_URL']}/#{vote.token}"
    client.short_url.shorten(url).urls.first.url_short
  end
end
