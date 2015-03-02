require 'csv'

class User < ActiveRecord::Base
  searchkick autocomplete: ['name'],
             suggest: ['name']

  def self.from_omniauth(auth)
    array = {
        "Testmodul1" => {
            "Steg1" => {
                "Video_1" => true,
                "Video_2" => true,
                "Quiz_1" => true,
                "Uppdrag_1" => true,
                "Quiz_2" => true
            },
            "Steg2" => {
                "Video_3" => true,
                "Video_4" => true,
                "Quiz_3" => true,
                "Uppdrag_2" => true,
                "Quiz_4" => true
            },
            "Examination" => {
                "Rattad" => true,
                "Klar" => true
            }
        }
    }
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.admin = true
      user.completion = array.to_json
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end


  def self.import(file)
    array = {
        "Testmodul1" => {
            "Steg1" => {
                "Video_1" => true,
                "Video_2" => true,
                "Quiz_1" => true,
                "Uppdrag_1" => true,
                "Quiz_2" => true
            },
            "Steg2" => {
                "Video_3" => true,
                "Video_4" => true,
                "Quiz_3" => true,
                "Uppdrag_2" => true,
                "Quiz_4" => true
            },
            "Examination" => {
                "Rattad" => true,
                "Klar" => true
            }
        }
    }
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      user = find_by_id(row["id"]) || new
      attributes = row.to_hash
      user.email = attributes['E-postadress']
      user.name = attributes['Förnamn'] + " " + attributes['Efternamn']
      user.completion = array.to_json
      user.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path)
      when ".xls" then Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end
end