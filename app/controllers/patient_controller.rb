class PatientController < ApplicationController
  def show
    @patient = Patient.find_by_patient_identifier(params[:id])
    @history = Dispensation.where("patient_id = ? and voided = ?",params[:id],false).order(dispensation_date: :desc).limit(10)
  end

  def ajax_patient

    date = params[:patient][:date_of_birth].to_date.strftime("%Y") rescue nil

    if  params[:patient][:first_name].blank?
      if params[:patient][:last_name].blank?
        rawPatients = Patient.where("voided = ? AND (birthdate LIKE ?)",false,
                                    "%#{date}%").pluck(:first_name, :last_name, :gender,:birthdate,:state,
                                                       :city,:patient_id)
      elsif date.blank?
        rawPatients = Patient.where("voided = ? AND (last_name LIKE ?)", false,
                                    "%#{params[:patient][:last_name]}%").pluck(:first_name, :last_name, :gender,
                                                                               :birthdate,:state, :city,:patient_id)
      else

        rawPatients = Patient.where("voided = ? AND (last_name LIKE ? OR birthdate LIKE ?)", false,
                                    "%#{params[:patient][:last_name]}%","%#{date}%").pluck(:first_name, :last_name,
                                                                                           :gender,:birthdate,:state,
                                                                                           :city,:patient_id)
      end
    else
      if params[:patient][:last_name].blank? and date.blank?
        rawPatients = Patient.where("voided = ? AND first_name LIKE ? ",
                                    false, "%#{params[:patient][:first_name]}%").pluck(:first_name, :last_name, :gender,
                                                                                       :birthdate,:state,:city,:patient_id)
      elsif params[:patient][:last_name].blank? and !date.blank?
        rawPatients = Patient.where("voided = ? AND (first_name LIKE ? OR birthdate LIKE ?)",
                                    false, "%#{params[:patient][:first_name]}%",
                                    "%#{date}%").pluck(:first_name, :last_name, :gender,:birthdate,:state,
                                                       :city,:patient_id)
      elsif date.blank? and !params[:patient][:last_name].blank?
        rawPatients = Patient.where("voided = ? AND (first_name LIKE ? OR last_name LIKE ?)", false,
                                    "%#{params[:patient][:first_name]}%",
                                    "%#{params[:patient][:last_name]}%").pluck(:first_name, :last_name, :gender,
                                                                               :birthdate,:state,:city,:patient_id)
      else

        rawPatients = Patient.where("voided = ? AND (first_name LIKE ? OR last_name LIKE ? OR birthdate LIKE ?)",
                                    false, "%#{params[:patient][:first_name]}%","%#{params[:patient][:last_name]}%",
                                    "%#{date}%").pluck(:first_name, :last_name, :gender,:birthdate,:state,:city,:patient_id)

      end
    end
    @patients =  view_context.patients(rawPatients)

    render "index"
  end

  def toggle_language_preference
    patient = Patient.find(params[:id])
    unless patient.blank?
      patient.language = (patient.language == "ENG"? "ESP" : "ENG")
      patient.save
      logger.info "Patient #{params[:id]} language preference switched by #{current_user.username}"
    end
    render :text => "done"
  end
end
