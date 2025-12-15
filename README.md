# Teste para desenvolvedor fullstack da empresa UEX Tecnologia

<img width="1155" height="522" alt="Image" src="https://github.com/user-attachments/assets/65108326-88c2-43e1-86bf-9a5459f5e6fc" />

## Consideracões iniciais

O teste consistia, basicamente em fazer um programa web que cadastrasse contatos com algumas informacões, entre elas o endereco. O programa deveria ter uma autenticacão completa, com gerenciamento de sessão e um cadastro de contatos. Um usuário deveria conseguir fazer um 'CRUD' completo de contatos, sendo que ao clicar em um dos contatos listados deveria mostrar em um mapa a localizacão exata do contato cadastrado.

### Observacões

1 - Os requisitos do projeto podem ser visualizados no pdf na raiz desse repositório sob o nome de 'teste-uex.pdf';

2 - Devido ao tempo curto (recebi o teste no dia 10/12/2025 e tive 4 dias para resolver, sendo que desses 4 dias só um deles foi um dia livre para realizar o teste), eu tomei algumas preocupacões de não perder muito tempo com algumas configuracões como docker e com algumas boas práticas. Me dediquei a entregar o "coracão" do teste dentro do prazo, como se fosse um MVP.

3 - No teste dizia que o código deveria ser limpo e comentado (No meu entendimento, em um código limpo não existem comentários). No caso da minha solucao, devido ao cumprimento do prazo, não me preocupei com o código limpo em 100% dos programas, e como 'código limpo' e 'comentado' serem duas coisas excludentes eu não escrevi nenhuma linha de comentário.

## Como rodar o projeto

### 1 - clone o repositório do backend feito com o framework ruby on rails:

https://github.com/Filipe-Leite/uex_contacts_backend.git

### 1.1 - clone o repositório do backend feito com o framework react:

https://github.com/Filipe-Leite/uex_contacts_frontend.git


### 2 - Dentro do repositório do backend dê os seguintes comandos:

bundle

rails db:create db:migrate

rails s

### 3 - Abra um outro terminal, vá ao diretório do frontend e dê os comandos:

npm install

npm start

### 3.1 - Crie um usuário:

- Vá à página de cadastro de usuário e se registre

### 4 - Popule o banco de dados:

- Os contatos estarão associados por chave estrangeira ao último usuário registrado.

#### 4.1 - No terminal, no diretório do backend, dê o comando:

rails db:seed

#### 5 - Com o frontend aberto faca o seu login. Você deve ser redirecionado para a home do projeto, onde devem conter os usuários previamente cadastrados.


#### 6 - Cadastre um novo usuário com endereco válido e procure por ele na tela home. Clique no contato. Você deve ver localizacão do seu novo contato no mapa

## O que foi usado?

### Liguagens de programacão

- Ruby
- Typescript

### Frameworks

- Ruby on rails (Back-end)
- React (Front-end)

### Banco de dados

- Postgres

### Bibliotecas e APIs

- geocoder
- geolocalization API do Google
- react-leaflet
- Devise token auth

## O que foi feito?

- Usuário pode se cadastrar para utilizar a plataforma;
- Usuário pode logar para utilizar a plataforma;
- Usuário pode realizar pesquisa de endereços como ajuda ao cadastro de contatos;
- Usuário pode cadastrar um contato;
- O sistema valida se o CPF é válido e único entre os usuários cadastrados;
- Integracão com google maps para obter coordenadas geográficas dos enderecos cadastrados;
- O logradouro, a cidade e a unidade federativa são preenchidos automaticamente ao digitar o cep no campo devido e clicar em 'search';
- Usuário pode usar o campo de busca para procurar o contato cadastrado;
- Usuário pode selecionar o contato cadastrado e ver a localizacão no mapa, marcada com um pin;
- Usuário pode fazer logout.

## O que não foi feito?
#### (até o momento que esse readme está sendo escrito)

- Usuário não pode recuperar a senha;
- Usuário não pode editar ou excluir contatos;
- Usuário não consegue fazer busca por CPF ou endereco, apenas por nome;
- Usuário não pode excluir a própria conta;
- Sistema de ajuda para o preenchimento do endereço do contato a cadastrar;
- Testes unitários.

