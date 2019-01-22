require 'nokogiri'
require 'open-uri'
require 'csv'
#require 'pry'
#récupère un email à partir d'une url d'une mairie du val d'oise

class Scrapper



#scrappe toutes les urls des sites des mairies du val d'oise
def get_townhall_urls
  url_générale = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
  url_mairies_array = []
  url_mairies = url_générale.xpath('//p/a/@href')
  url_mairies.each do |urls|
     url_finale = urls.text[1..-1]
     url_mairies_array << url_finale.to_s
	end
  return url_mairies_array
end
#scrap les urls des sites des mairies du 92
def get_townhall_email
  array1 = []
  get_townhall_urls.each do |i|
    url = Nokogiri::HTML(open("http://annuaire-des-mairies.com/#{i}"))
    n = url.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]')
    array1 << n.text.to_s
  end
  return array1
end


#scrappe tous les noms de villes du val d'oise
  def get_townhall_names
    url_générale = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
    names_mairies_array = []
    names_mairies = url_générale.xpath('//p/a')
    names_mairies.each do |urls|
       names = urls.text
       names_mairies_array << names
  	end
    return names_mairies_array
  end
  #méthode json qui write les e-mails et les noms de chaque mairie du 92
  def save_as_json(emails)
    File.open("db/emails.json","w") do |f|
    f.write(JSON.pretty_generate(emails))
    end
  end
  #méthode pour enregistrer les donnés sur un spreadsheet google
  def save_as_spreadsheet(hashhh)
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1A37vEpo0XCoDjhAarvBwMFmFxHhBWdenaUWiO8w5AQw").worksheets[0]
    hashhh.each_key.with_index do |key, count|
      ws[count+1, 1] = key
    end
      hashhh.each_value.with_index do |value, count|
        ws[count+1, 2] = value
      end
      ws.save
  end
  #méthode qui enregistre les donnés sur un fichier.csv
  def save_as_csv(hashhh)
    csv = CSV.open("db/emails.csv", "wb")
      hashhh.each do |key, value|

      csv  << [key, value]
    end
  end

#fusionne les deux arrays en un array de hashs au format (ville => e-mail mairie)
def perform
  final_array = []
  names = get_townhall_names
  email = get_townhall_email
  final_hash = Hash[names.zip(email)]
  save_as_json(final_hash)
  save_as_spreadsheet(final_hash)
  save_as_csv(final_hash)
end
end
