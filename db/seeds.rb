puts "Criando contatos..."

usuario = User.last

if usuario.nil?
  puts "Precisa ter um usuário cadastrado"
  exit
end

# CPFs válidos de exemplo (apenas para teste)
cpfs_validos = [
  "123.456.789-09",
  "987.654.321-00",
  "111.222.333-96",
  "444.555.666-97",
  "777.888.999-98",
  "000.111.222-99",
  "333.444.555-10",
  "666.777.888-20",
  "999.000.111-30",
  "222.333.444-40"
]

nomes = [
  "João Silva",
  "Maria Santos", 
  "Carlos Oliveira",
  "Ana Souza",
  "Pedro Lima",
  "Fernanda Costa",
  "Rafael Alves",
  "Juliana Pereira",
  "Luiz Rodrigues",
  "Patrícia Fernandes"
]

nomes.each_with_index do |nome, i|
  contato = Contact.new(
    user_id: usuario.id,
    name: nome,
    cpf: cpfs_validos[i] || "123.456.789-09",
    phone: "(#{rand(11..99)}) #{rand(9000..9999)}-#{rand(1000..9999)}",
    cep: "#{rand(10000..99999)}-#{rand(100..999)}",
    street: "Rua #{['A', 'B', 'C', 'D'].sample}",
    number: rand(1..1000).to_s,
    neighborhood: "Centro",
    city: "São Paulo",
    state: "SP"
  )

  if contato.save
    puts "Criado: #{contato.name}"
  else
    puts "Erro em #{nome}: #{contato.errors.full_messages.join(', ')}"
    # Tenta sem CPF se for opcional
    contato.cpf = nil
    if contato.save
      puts "Criado sem CPF: #{contato.name}"
    end
  end
end

puts "Feito. Total: #{Contact.count}"