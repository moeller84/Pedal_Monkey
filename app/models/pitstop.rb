class Pitstop < ApplicationRecord

  belongs_to :start_stage, class_name: "Stage", foreign_key: "start_stage_id", optional: :final_stop?
  belongs_to :end_stage, class_name: "Stage", foreign_key: "end_stage_id", optional: :first_stop?

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  # reverse_geocoded_by :latitude, :longitude,
  # :address => :location
  # after_validation :reverse_geocode

  def final_stop?
    self.end_stage ? self.end_stage.trip.stages.count == self.end_stage.stage_no : false
  end

  def first_stop?
    self.start_stage&.stage_no == 1
  end

  def self.pitstops_create_first(first_stage, start_address)
    # 4.1 Creating first pitstop with FROM value from form / assign to first stage
    first_pitstop = Pitstop.new
    first_pitstop.start_stage = first_stage
    first_pitstop.address = start_address
    first_pitstop.save
  end

  def self.pitstops_create_rest(trip)
    # 4.2 Iteration for creating remaining pitstops minus the last one
    pitstops = trip.stages.count # UNLESS TRIP IS ONLY ONE DAY?
    assign_counter = 1
    assign_stage = trip.find_stage(assign_counter)

    (pitstops - 1).times do
      pitstop = Pitstop.new
      pitstop.end_stage = assign_stage
      assign_counter += 1
      assign_stage = trip.find_stage(assign_counter)
      pitstop.start_stage = assign_stage
      pitstop.save
    end
  end
  
  def self.pitstops_create_last(end_address, trip)
    # 4.3 Creating last pitstop
    pitstop = Pitstop.new
    pitstop.end_stage = trip.find_stage(trip.stages.count)
    pitstop.address = end_address
    pitstop.save
  end
end