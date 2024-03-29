require "httparty"
require "nokogiri"
games = ["pokedex-sv"]
pokemon_target = "sylveon"
is_move = false
is_egg_move = false
is_over = false
needs_description = false

level_acquire = ""
name = ""
type_string = ""
category_string = ""
power_points = ""
power = ""
accuracy = ""
effect_percent = ""
description = ""

pokemon_product_index = -1
pokemon_products = []

MovesetProduct = Struct.new(:index, :level_acquire, :name, :type, :category, :pp, :power, :accuracy, :effect_percent, :description)

games.each do |game|
  response = HTTParty.get("https://www.serebii.net/#{game}/#{pokemon_target}/")
  document = Nokogiri::HTML(response.body)
  html_products = document.css("table.dextable")
  html_products = html_products.css("tr")

  html_products.each do |html_product|
    info = "#{html_product.css("td").text} "
    inforaw = html_product.css("td")
    img_check = inforaw.css("img")

    if !(info.inspect == "\" \"")
      puts "THIS IS ITERATION--------------------------------------------------------: #{pokemon_product_index}"
      puts "needs_description is #{needs_description}"
      if needs_description == false
        info = []
      end
      typeimage = []
      pokemon_product_index += 1

      #this code sets the :info attribute of PokemonProduct
      if is_over == false
        inforaw.each do |item|
          tempinfo = []
          clean_inspect = item.text.inspect.gsub("\\r\\n\\t", "")
          clean_inspect = clean_inspect.gsub("\\t", "")
          clean_inspect = clean_inspect.gsub!(/[^0-9A-Za-z.,—?\s-]/, "")

          # puts "this is Clean_Inspect: #{clean_inspect}"
          tempinfo << clean_inspect
          puts "This is tempinfo: #{tempinfo}"
          if tempinfo[0] == "Standard Level Up"
            is_move = true
          elsif tempinfo[0] == "Stats"
            is_move = false
            is_egg_move = false
            is_over = true
          elsif tempinfo[0] == "Egg Moves Details"
            is_egg_move = true
          end 

          if is_move == true
            tempinfo.each do |item|
              if item.match?(/[0-9A-Za-z—? -]/)
                # puts "IT WORKS"
                info << item
              end
            end
          end
          # puts "AGAIN WE DO THIS: #{info}"
        end
      

        # pp "info is #{info}"
        # pp "info1 -------------#{info[1]}"
        if needs_description == false
          if is_egg_move == false
            level_acquire = info[0]
            name = info[1]
            power = info[2]
            accuracy = info[3]
            power_points = info[4]
            effect_percent = info[5]
          else
            level_acquire = "Egg"
            name = info[0]
            power = info[1]
            accuracy = info[2]
            power_points = info[3]
            effect_percent = info[4]
          end
        else
          description = info
        end

        if is_move == true && info[1]
          img_check = inforaw.css("img")
          # puts img_check
          if !img_check.empty?
            url = "https://www.serebii.net" + html_product.css("a").first.attribute("href").value
            img_check.each do |image_url|
              #puts "This is image_url: #{image_url}"
              #puts "this is image_url.css: #{image_url.attribute("src").value}"
              typeimage << "https://www.serebii.net" + image_url.attribute("src").value
            end

            type_url = typeimage[0]
            category_url = typeimage[1]

            #--------- testing parsing out type from substring
            type_string = type_url.match(/(?<=type\/)(.*)(?=(.gif))/).to_s
            category_string = category_url.match(/(?<=type\/)(.*)(?=(.png))/).to_s

            pp type_string
            pp category_string
          end

          if info.length > 1 && needs_description == false
            # puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
            needs_description = true
            next
          end
          pokemon_product = MovesetProduct.new(pokemon_product_index, level_acquire, name, type_string, category_string, power_points, power, accuracy, effect_percent, description)
          pokemon_products.push(pokemon_product)
          # puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
          needs_description = false
        else
          pokemon_product_index += -1
        end
      end

    end
  end
end

csv_headers = ["index", "level/acquire","name", "type", "category", "pp", "power", "accuracy", "effect_percent", "description"]
CSV.open("output.csv", "wb", write_headers: true, headers: csv_headers) do |csv|
  pokemon_products.each do |pokemon_product|
    csv << pokemon_product
  end
end