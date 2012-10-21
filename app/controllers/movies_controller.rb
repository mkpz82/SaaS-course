class MoviesController < ApplicationController

  attr_reader :title_header, :release_date_header, :all_ratings, :selected_ratings
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.scoped
    @all_ratings = find_ratings
    
    if params['sort'] then
      @movies = sort_by params['sort'].to_sym
    end
      
    @movies = find_movies_by_ratings
    
    if params[:ratings] then
      session[:ratings] = params[:ratings]
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def sort_by(column)
    
    if column == :title then
      @title_header = 'hilite'
      @release_date_header = ''
    else
      @title_header = ''
      @release_date_header = 'hilite'
    end
    
    @movies.order(column)
  end
  
  def find_ratings
     @all_ratings=Movie.select(:rating).map(&:rating).uniq
  end
 
  def find_movies_by_ratings
    if params[:ratings] then
      @selected_ratings = params[:ratings].any? ? params[:ratings] : session[:ratings]
    elsif session[:ratings] then
      @selected_ratings = session[:ratings]
    else
      @selected_ratings = @all_ratings
    end
    
    if @selected_ratings.is_a? Hash then @movies.where(:rating => @selected_ratings.keys)
    else @movies end
  end
end
