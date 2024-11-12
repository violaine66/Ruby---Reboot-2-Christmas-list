require 'open-uri'
require 'nokogiri'
require 'csv'
filepath = 'gifts.csv'

puts "Welcome to your Christmas gift list!"
puts "**************************************"
sleep(1)
array = []
# On va lire le fichier gifts csv et on va integrer chque colonne dans le tableau array initialisé (parsing)
CSV.foreach(filepath, col_sep: ',', quote_char: '"', headers: :first_row) do |row|
  # chaque élèment du tableau est un hash avec une clé name et une clé bought
  array << { name: row['name'], achat: row['bought'] == 'true' }
end
# Si le tableau n'est pas vide, on va afficher la liste déjà constituée et enregistrée
if array.empty? == false
  puts "Nice to see you again ! Here is your list:"
  array.each_with_index do |gift, i|
    # on convertit la vaeur de la clé achat qui est un boléen
    marked = gift[:achat] ? "[X]" : "[ ]"
    # pour chaque chaque element ou gift du tableau on affiche son index et ses valeurs
    puts "#{i + 1} #{marked} #{gift[:name]}"
  end
end
# on commence la boucle
loop do
  puts "Which action [list|add|delete|mark|quit|idea]?"
  print "> "
  user_answer = gets.chomp

  # si l'utilisateur tape le mot list
  case user_answer
  when "list"
    # si la liste(tableau) est vide, on l'en informe
    if array.empty?
      puts "your list is empty"
    # sinon on lui affiche le numero de l'elèment(cadeau) qui est l'index du tableau, ainsi que les valeurs de ses deux
    # clés, achat et name
    else
      array.each_with_index do |gift, i|
        marked = gift[:achat] ? "[X]" : "[ ]"
        puts "#{i + 1} #{marked} #{gift[:name]}"
      end
    end

  # si l'utilisateur tape ajouter on rajoute la saisie dans le tableau, sous forme de hash avec pour clés achat et name
  when "add"
    puts "Add an item please :"
    print "> "
    item_to_add = gets.chomp
    array << { name: item_to_add, achat: false }
    puts "#{item_to_add} has been added to your list"

  # si l'utilisateur tape supprimer, on l'informe si sa liste est vide
  when "delete"
    if array.empty?
      puts "your list is empty"
    else
      # sinon on lui affiche à nouveau la liste pour qu'il choisisse le numéro à supprimer
      puts "which is the number of item you want to delete ?"
      array.each_with_index do |gift, i|
        marked = gift[:achat] ? "[X]" : "[ ]"
        puts "#{i + 1} #{marked} #{gift[:name]}"
      end
      # on supprime le hash ayant pour index le numéro saisie
      print "> "
      item_delete = gets.chomp.to_i
      # on sassure que le nombre saisi soit bien compris dans l'intervalle des nombres affichés (pour ne pas supprimer
      # le dernier item en cas de mauvaise saisie!)
      if item_delete.between?(0, array.size + 1)
        item_deleted = array.delete_at(item_delete - 1)
        puts " #{item_deleted[:name]} has been deleted to your list"
      else
        puts "It's not a valid answer, please, try again "
      end
    end

  # si l'utilisateur tape mark, on vérifie si sa liste est remplie, sinon on en l'informe
  when "mark"
    if array.empty?
      puts "your list is empty"
    else
      # on imprime la liste à l'utilisateur pour qu'il puisse choisir quel numero acheter
      array.each_with_index do |gift, i|
        marked = gift[:achat] ? "[X]" : "[ ]"
        puts "#{i + 1} - #{marked} #{gift[:name]}"
      end
      puts "Which item have you bought (give the number of item)?"
      print "> "
      # on va changer la valeur de la clé achat pour la transformer en true
      item_bought = gets.chomp.to_i
      array[item_bought - 1][:achat] = true
      puts "#{array[item_bought - 1][:name]} has been bought"
    end

  # Si l'utilisateur tape idea on va scraper le site etsy
  when "idea"
    puts "What are you looking for?"
    print "> "
    search = gets.chomp
    # url dynamique pour intégrer la saisie search de l'uilisateur
    url = "https://letsy.lewagon.com/products?search=#{search}"
    html_content = URI.open(url).read
    ideas = []
    doc = Nokogiri::HTML.parse(html_content)
    doc.search('.title').each do |element|
      ideas << element.text.strip
    end
    puts " Here are results for #{search}:"
    ideas.each_with_index.map do |element, i|
      puts "#{i + 1} - #{element}"
    end
    # s'il n'y a pas d'url correspondant à sa recherche on l'en informe
    if ideas.empty?
      puts "Sorry. there's no article corresponds to your request"
    else
      # sinon on intégre sa saisie au tableau, sous forme de hash
      puts "Pick one to add to your list (give the number)"
      pick_one = gets.chomp.to_i
      pick = ideas[pick_one - 1]
      array << { name: pick, achat: false }
      puts "#{pick} has been added to your list"
    end

  # au moment de quitter, on va enregistrer la liste dans le dossier gifts csv
  when "quit"
    filepath = 'gifts.csv'
    CSV.open(filepath, 'wb', col_sep: ',', force_quotes: true, quote_char: '"') do |csv|
      csv << ['name', 'bought']
      array.each do |element|
        csv << [element[:name], element[:achat] ? 'true' : 'false']
      end
    end
    puts "thank you, goodbye!"
    # la boucle se termine
    break

  else
    puts "It's not a valid answer, please, try again "
  end
end
