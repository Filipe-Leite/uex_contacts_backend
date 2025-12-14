class SearchController < ApplicationController
  before_action :authenticate_user!

  def index

      @results = search_records(params[:q])

      render json: @results, status: :ok
  end

  private

  def search_records(query)
    
    if query != ""
      query = "#{query&.strip}%"
      search_contact(query)
    else
      []
    end
  end

  def search_contact(query)
    contacts = Contact.all.order(name: :asc)

    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    p "query>>>>, #{query}"
    if query.present?
      lower_query = query.downcase
      contacts = contacts.where("LOWER(name) LIKE ?", "%#{lower_query}%")
    end
    
    # disciplines.paginate(page: page, per_page: 10)
  end

end
