class TopicsCell < Cell::Rails
  helper :application

  def list(paged_votes, user, loading_url)
    @paged_votes = paged_votes
    @user = user
    @loading_url = loading_url
    render
  end

  def topic_options(vote_items, user)
    @vote_items = vote_items
    @user = user
    render
  end

  def infocard(infocard)
    @infocard = infocard
    return '' if @infocard.blank?
    render
  end

  # 新建议题页面的顶栏
  def new_form_topbar(options = {})
    @step_count = options[:step_count] || 2
    render
  end

  # 新建议题页面：输入议题描述子表单
  def new_form_part_tdesc(options = {})
    @step_num = options[:step_num]
    raise '请输入子表单序号参数' if @step_num.blank?
    render
  end

  # 新建议题页面：输入议题选项子表单
  def new_form_part_titems(options = {})
    @step_num = options[:step_num]
    raise '请输入子表单序号参数' if @step_num.blank?
    render
  end

  # 新建议题页面：读取商品网址子表单
  def new_form_part_topenurl(options = {})
    @step_num = options[:step_num]
    raise '请输入子表单序号参数' if @step_num.blank?
    render
  end
end