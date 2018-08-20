User.create!(name: "Admi  n",
  email: "admin@gmail.com",
  password: "111111",
  password_confirmation: "111111",
  role: 0)

User.create!(name: "Librarian",
  email: "librarian@gmail.com",
  password: "111111",
  password_confirmation: "111111",
  role: 1)

100.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "111111"
  User.create!(name: name,
    email: email,
    password: password,
    password_confirmation: password,
    role: 2)
end

User.first.confirm
User.second.confirm
User.find(3).confirm

100.times do
  name = Faker::Book.author
  address = Faker::Address.full_address
  phone = Faker::PhoneNumber.cell_phone
  Author.create!(name: name,
    address: address,
    phone: phone)
end

10.times do
  category = Faker::Book.genre
  Category.create!(name: category)
end

10.times do
  publisher = Faker::Book.publisher
  address = Faker::Address.full_address
  phone = Faker::PhoneNumber.cell_phone
  Publisher.create!(name: publisher,
    address: address,
    phone: phone)
end

Card.create!(issued_date: Date.parse("2018-07-25"),
  expired_date: Date.parse("2019-01-02"),
  user_id: 3)

100.times do |n|
  title = Faker::Book.title
  price = (1+rand(1000)) * 1000
  isbn = n
  publisher_id = Publisher.all.sample.id
  category_id = Category.all.sample.id
  Book.create!(title: title,
    price: price,
    isbn: isbn,
    publisher_id: publisher_id,
    category_id: category_id)
end

100.times do
  book_id = Book.all.sample.id
  author_id = Author.all.sample.id
  AuthorBook.create!(book_id: book_id,
    author_id: author_id)
end

100.times do
  status = rand(2)
  book_id = Book.all.sample.id
  Copy.create!(status: status,
    book_id: book_id)
end
