module Utils
  extend ActiveSupport::Concern

  included do
  end

  def set_logged_in_cookie
    cookies[:logged_in] = true
  end

  def destroy_logged_in_cookie
    cookies.delete(:logged_in)
  end

  def login_redirect_path
    path = session[:return_to_url] || request.env['HTTP_REFERER'] || root_path
    session[:return_to_url] = nil
    path = root_path if path == login_path
    path
  end

  def to_bool(string)
    return true if string == true || string =~ (/(true|t|yes|y|1)$/i)
    return false if string == false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
  end

  def save_object(obj, params_hash)
    obj.assign_attributes(params_hash)
    changes = obj.changes
    if obj.valid? && obj.save
      obj_name = obj.class.name.underscore
      event_type = params[:action] == 'create' ? 'created' : 'updated'
      EventBus.publish "#{obj_name}_#{event_type}", obj_name.to_sym => obj, current_user: current_user, changes: changes
      flash[:notice] = t('flash.saved')
      render json: {redirect: polymorphic_path([obj])}
    else
      render json: {errors: obj.errors.messages}, status: :unprocessable_entity
    end
  end

  def find_polymorphic_object
    _obj = _find_polymorphic_object_from_uri request
    instance_variable_set "@#{_obj.class.name.underscore}", _obj  # set var and return the obj
  end

  def find_object_from_referer
    _find_polymorphic_object_from_uri URI(request.referer)
  end

  def find_polymorphic_model
    resource = request.path.split('/')[1]
    resource.classify.constantize
  end

  def paginate(collection, page = nil, per = nil)
    page ||= params[:page]
    per  ||= params[:per]
    collection = Kaminari.paginate_array collection if collection.kind_of? Array
    collection.try(:page, page).try(:per, per)
  end

  def cleaned_contacts(_params)
    _params ||= {}
    (_params[:contacts]  || {}).delete_if { |key, value| value.blank? }
  end

  def cleaned_tags(_params, field_name=:tags)
    (_params[field_name] || '').split(',')
  end

  def cleaned_additional_info(_params)
    yaml = _params[:additional_info]
    (yaml && !yaml.empty?) ? SafeYAML.load(yaml, safe: true) : nil
  end

  def cleaned_relations_attributes(_params)
    _attrs = JSON.parse _params[:relations_attributes]
    _attrs.map do |r|
      OpenStruct.new(
        id:        (r['id'].blank? ? nil : r['id'].to_i    ),
        target:    (r['target']['id'].blank? ? nil : r['target']['id'].to_i),
        direction: r['type'].split('_').last,       # something_dir => dir
        rel_type:  r['type'].gsub(/_dir|_rev/, ''), # something_dir => something
        metadata:  cleaned_relation_metadata(r['metadata']),
      )
    end
  end

  def cleaned_relation_metadata(m)
    OpenStruct.new(
      description: m['description'].blank? ? nil : m['description'],
      start_date:  m['start_date'].blank? ? nil : Date.parse(m['start_date']),
      end_date:    m['end_date'].blank?   ? nil : Date.parse(m['end_date']),
      currency:    m['amount'].blank? ? nil : m['currency'],
      amount:      m['amount'].blank? ? nil : m['amount'].to_f,
    )
  end

  def cleaned_layers_attributes(_params)
    _attrs = JSON.parse _params[:layers_attributes]
    _attrs.map do |layer|
      OpenStruct.new(
        id:           layer['id'].blank? ? nil : layer['id'].to_i,
        name:         layer['name'].blank? ? nil : layer['name'],
        fill_color:   layer['fill_color'].blank? ? nil : layer['fill_color'],
        stroke_color: layer['stroke_color'].blank? ? nil : layer['stroke_color'],
        visible:      layer['visible'].nil? ? true : layer['visible'],
        position:     layer['position'].blank? ? nil : layer['position'].to_i,
        rule:         layer['rule'].blank? ? nil : layer['rule'],
      )
    end
  end

  def cleaned_location(_params)
    GeoJSON.parse(_params[:location])
  end

  def flash_xhr(msg)
    flash.now[:notice] = msg
    render_to_string(partial: 'shared/alerts')
  end

  def news_feed_results(all = false)
    if all || !current_user
      activities = paginate PublicActivity::Activity.order('created_at desc').includes(:trackable, :owner)
    else
      activities = paginate current_user.following_activities.includes(:owner)
    end
    activities
  end

  protected

    def _find_polymorphic_object_from_uri(uri)
      resource, id = uri.path.split('/')[1..2]
      _model = resource.classify.constantize
      _model.find(id)
    end
end
