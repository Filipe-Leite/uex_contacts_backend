puts "Criando 50 contatos com localização..."

usuario = User.last

if usuario.nil?
  puts "Precisa ter um usuário cadastrado"
  exit
end

cidades = [
  { cidade: "São Paulo", estado: "SP", lat: -23.5505, lng: -46.6333 },
  { cidade: "Rio de Janeiro", estado: "RJ", lat: -22.9068, lng: -43.1729 },
  { cidade: "Belo Horizonte", estado: "MG", lat: -19.9167, lng: -43.9345 },
  { cidade: "Porto Alegre", estado: "RS", lat: -30.0331, lng: -51.23 },
  { cidade: "Salvador", estado: "BA", lat: -12.9714, lng: -38.5014 },
  { cidade: "Brasília", estado: "DF", lat: -15.7801, lng: -47.9292 },
  { cidade: "Fortaleza", estado: "CE", lat: -3.7319, lng: -38.5267 },
  { cidade: "Curitiba", estado: "PR", lat: -25.4284, lng: -49.2733 },
  { cidade: "Recife", estado: "PE", lat: -8.0476, lng: -34.877 },
  { cidade: "Manaus", estado: "AM", lat: -3.119, lng: -60.0217 },
  { cidade: "Goiânia", estado: "GO", lat: -16.6869, lng: -49.2648 },
  { cidade: "Belém", estado: "PA", lat: -1.4558, lng: -48.4902 },
  { cidade: "Florianópolis", estado: "SC", lat: -27.5954, lng: -48.548 },
  { cidade: "Vitória", estado: "ES", lat: -20.3155, lng: -40.3128 },
  { cidade: "Campo Grande", estado: "MS", lat: -20.4697, lng: -54.6201 },
  { cidade: "Cuiabá", estado: "MT", lat: -15.601, lng: -56.0974 },
  { cidade: "São Luís", estado: "MA", lat: -2.5391, lng: -44.2829 },
  { cidade: "João Pessoa", estado: "PB", lat: -7.1153, lng: -34.861 },
  { cidade: "Maceió", estado: "AL", lat: -9.6658, lng: -35.735 },
  { cidade: "Teresina", estado: "PI", lat: -5.0919, lng: -42.8034 }
]

nomes_masculinos = ["João", "Carlos", "Pedro", "Paulo", "Luiz", "Marcos", "Rafael", "André", "Fernando", "Ricardo", "Eduardo", "Roberto", "Bruno", "Diego", "Fábio", "Gustavo", "Hélio", "Igor", "Jorge", "Leonardo"]
nomes_femininos = ["Maria", "Ana", "Juliana", "Patrícia", "Fernanda", "Camila", "Amanda", "Beatriz", "Cristina", "Daniela", "Elaine", "Gabriela", "Helena", "Isabela", "Jéssica", "Larissa", "Mariana", "Natália", "Olivia", "Priscila"]
sobrenomes = ["Silva", "Santos", "Oliveira", "Souza", "Rodrigues", "Ferreira", "Alves", "Lima", "Gomes", "Costa", "Ribeiro", "Martins", "Carvalho", "Almeida", "Pereira", "Nascimento", "Araújo", "Rocha", "Moreira", "Barbosa"]

ruas = ["das Flores", "dos Coqueiros", "Principal", "Comercial", "das Palmeiras", "Central", "15 de Novembro", "7 de Setembro", "Brasil", "Paulista", "Augusta", "Vergueiro", "Consolação", "Ipiranga", "Anhangabaú"]
bairros = ["Centro", "Jardins", "Vila Mariana", "Moema", "Pinheiros", "Copacabana", "Ipanema", "Leblon", "Barra", "Tijuca", "Santa Cecilia", "Perdizes", "Lapa", "Bela Vista", "Cambuci"]

50.times do |i|
  cidade = cidades.sample
  nome = "#{[*nomes_masculinos, *nomes_femininos].sample} #{sobrenomes.sample}"
  cpf = "#{rand(100..999)}.#{rand(100..999)}.#{rand(100..999)}-#{rand(10..99)}"
  
  contato = Contact.new(
    user_id: usuario.id,
    name: nome,
    cpf: cpf,
    phone: "(#{rand(11..99)}) 9#{rand(1000..9999)}-#{rand(1000..9999)}",
    cep: "#{rand(10000..99999)}-#{rand(100..999)}",
    street: "Rua #{ruas.sample}",
    number: rand(1..2000).to_s,
    complement: ["Apto #{rand(1..200)}", "Casa #{rand(1..50)}", "Sala #{rand(1..50)}", "Bloco #{rand(1..10)}", nil, nil, nil].sample,
    neighborhood: bairros.sample,
    city: cidade[:cidade],
    state: cidade[:estado],
    latitude: cidade[:lat] + rand(-0.05..0.05),
    longitude: cidade[:lng] + rand(-0.05..0.05)
  )

  if contato.save
    puts "#{i+1}. #{nome} - #{cidade[:cidade]}/#{cidade[:estado]}"
  else
    contato.cpf = nil
    if contato.save
      puts "#{i+1}. #{nome} (sem CPF) - #{cidade[:cidade]}/#{cidade[:estado]}"
    else
      contato.save(validate: false)
      puts "#{i+1}. #{nome} (forçado) - #{cidade[:cidade]}/#{cidade[:estado]}"
    end
  end
end

puts ""
puts "Concluído!"
puts "Total de contatos no banco: #{Contact.count}"