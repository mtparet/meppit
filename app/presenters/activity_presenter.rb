class ActivityPresenter
  include Presenter

  required_keys :object, :ctx

  def trackable
    @trackable ||= object.trackable
  end

  def owner
    @owner ||= object.owner
  end

  def name
    trackable.try(:name)
  end

  def url
    ctx.url_for trackable
  end

  def type
    ctx.object_type trackable
  end

  def avatar
    object_avatar trackable, !user_itself?
  end

  def owner_avatar
    object_avatar owner
  end

  def object_avatar(obj, allow_image = true)
    return ctx.image_tag obj.avatar.thumb.url if obj.try(:avatar) && allow_image

    case type
    when :map      then ctx.icon :globe
    when :geo_data then ctx.icon :'map-marker'
    when :user     then ctx.icon :user
    else ctx.icon :question
    end
  end

  def changes
    changeset = object.parameters[:changes]
    if changeset.nil? || changeset.empty?
      ""
    else
      ctx.icon("edit", changeset.keys.to_sentence).html_safe
    end
  end

  def time
    object.created_at
  end

  def time_ago
    ctx.t('time_ago', time: ctx.time_ago_in_words(time))
  end

  def event
    "<span class=\"event-type\">#{ event_type }</span> #{headline}".html_safe
  end

  def event_with_owner
    "#{ owner_link } <span class=\"event-type\">#{ event_type }</span> #{headline}".html_safe
  end

  def owner_link
    ctx.link_to(owner.name, ctx.url_for(owner), class: "event-owner").html_safe
  end

  def event_type
    ctx.t "activities.event.#{object.key.split('.').last}"
  end

  def user_itself?
    # using `owner_id` instead of `owner` to avoid unnecessary `includes(:owner)`
    type == :user && trackable.id == object.owner_id
  end

  def headline
    text = user_itself? ? ctx.t("profile") : name
    ctx.link_to(text, url, class: "trackable").html_safe
  end
end
