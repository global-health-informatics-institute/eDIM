class LocationsController < ApplicationController
  def suggestions
    workstation_id = LocationTag.select(:location_tag_id).where(name: 'workstation location').first
    locations = workstation_id.location_tag_map.collect{|x| x.location_id}
    names = Location.select(:name, :location_id).where("name LIKE '%#{params[:search_string]}%'
                                                        AND location_id in (?)", locations).map do |v|
      "<li value=\"#{v.location_id}\">#{v.name}</li>"
    end

    facilities= Location.select(:name,:location_id).where("name LIKE '%#{params[:search_string]}%' AND description = ?",
                                                          'Health Centre , Public Health Facility').map do |v|
      "<li value=\"#{v.location_id}\">#{v.name}</li>"
    end

    render :text => names.join('') + facilities.join('')
  end

  def search

    workstation_id = LocationTag.select(:location_tag_id).where(name: 'workstation location')
    locations = LocationTagMap.where(location_tag_id: workstation_id.collect{|i| i.location_tag_id}).collect{|x| x.location_id}
    names = Location.select(:name, :location_id).where("name LIKE '%#{params[:search_string]}%'
                                                        AND location_id in (?)", locations).map do |v|
      "<li value=\"#{v.location_id}\">#{v.name}</li>"
    end

    render :text => names.join('')

  end

  def print_label

    print_string = Misc.print_location(params[:location])
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
              :filename=>"#{(0..8).map { (65 + rand(26)).chr }.join}.lbl", :disposition => "inline")
  end

  def index
    render :layout => 'touch'
  end

  def show
    location = (Location.find_by_location_id(params[:location]) || Location.find_by_name(params[:location]))
    print_and_redirect("/locations/print_label?location=#{location.id}", "/")
  end

  def new
    render :layout => 'touch'
  end

  def create

    if Location.find_by_name(params[:location]).blank?
      location = Location.new
      location.name = params[:location]
      location.creator  = User.current.id.to_s
      location.date_created  = Time.current.strftime("%Y-%m-%d %H:%M:%S")
      location.save

      location_tag_map = LocationTagMap.new
      location_tag_map.location_id = location.id
      location_tag_map.location_tag_id = LocationTag.where(name: 'Workstation location').first.id rescue nil
      result = location_tag_map.save

      if result == true then
        flash[:success] = "location #{params[:location]} added successfully"
      else
        flash[:error] = "location #{params[:location]} addition failed"
      end
    else
      location_id = Location.find_by_name(params[:location]).id
      location_tag_id = LocationTag.find_by_name("Workstation location").id
      location_tag_map = LocationTagMap.where(location_id: location_id, location_tag_id: location_tag_id).first_or_initialize

      result = location_tag_map.save

      if result == true then
        flash[:notice] = "location #{params[:location]} added successfully"
      else
        flash[:notice] = "<span style='color:red; display:block; background-color:#DDDDDD;'>location #{params[:location]} addition failed</span>"
      end
    end

    redirect_to "/" and return

  end

end
