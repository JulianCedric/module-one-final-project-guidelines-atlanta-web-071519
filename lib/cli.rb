class CLI
    attr_reader :user
    def run
        @prompt = TTY::Prompt.new
        puts "\n\n==============="
        puts "Welcome to Movies on Command! Discover and rate any movies you watch or are interested in."
        puts "==============="
        # sleep 3
        while true
            main_menu
        end
    end

    def main_menu
        choices = ["Login/signup", "Read a Review", "Write a Review", "Update a Review", "Exit"]
        choice = @prompt.enum_select("Please select one of the following:", choices)
        if choice == "Login/signup"
            login
        elsif choice == "Read a Review"
            read_review
        elsif choice == "Write a Review"
            write_review
        elsif choice == "Update a Review"
            update_review
        elsif choice == "Exit"
            exit
        end
    end




    def login
        puts "What's your name?"
        name = gets.chomp
        @user = User.find_or_create_by(name: name)
    end

    def read_review
        choices = []
        Review.all.each do |review|
            movie = Movie.find_by(id: review.movie_id)
            choices << "#{movie.title}"
        end
        choice = @prompt.enum_select("Please select a movie to read its reviews:", choices)
        movie_selected = Movie.find_by(title: choice)
        review = Review.where(movie_id: movie_selected.id)
        review.each do |r|
            person = User.find_by(id: r.user_id)
            puts "\n#{person.name}'s review:"
            puts "rating: #{r.rating}/5"
            puts "notes: #{r.notes}"
            puts
            #sleep 5
        end
    end
    
    def write_review
        if @user
            #binding.pry
            puts "What's the name of the movie that you would like to write a review about?"
            movie_title = gets.chomp
            puts "Great! What would you rate #{movie_title} on a scale of 1 to 5?"
            movie_rating = gets.chomp
            puts "What notes do you have about #{movie_title}?"
            movie_notes = gets.chomp
            movie = Movie.find_or_create_by(title: movie_title)
            review = Review.create(user_id: self.user.id, movie_id: movie.id, rating: movie_rating, notes: movie_notes)
        else 
            puts "\n\nYou must be logged in to write a review. Please log in or sign up."
            sleep 3
        end
    end
    def update_review
        choices = []
        if @user
            users_reviews = Review.where(user_id: self.user.id)
            users_reviews.each do |review|
                user_movie = Movie.find_by(id: review.movie_id)
                choices << "#{user_movie.title}"
            end
            choice = @prompt.enum_select("Here's a list of movies that you have reviewed. Which one would you like to update?", choices)
            chosen_movie = Movie.find_by(title: choice)
            chosen_review = Review.find_by(movie_id: chosen_movie.id)
            puts "You originally rated this movie a #{chosen_review.rating}/5. What is your updated rating?"
            puts "note - you can rate it the same if you just want to update your notes."
            new_rating = gets.chomp
            puts "\nbelow are the notes:\n"
            puts "#{chosen_review.notes}"
            selection = @prompt.enum_select("Would you like to overwrite or append to your notes?", ["Overwrite", "Append to"])
            if selection == "Overwrite"
                puts "What are your new notes for #{chosen_movie.title}"
                new_notes = gets.chomp
                chosen_review.update(notes: new_notes, rating: new_rating)
            elsif "Append to"
                puts "What would you like to add to your notes?"
                appended_notes = "... " + gets.chomp
                final_notes = chosen_review.notes << appended_notes
                chosen_review.update(notes: final_notes, rating: new_rating)
            end
        else 
            puts "\n\nYou must be logged in to update your reviews. Please log in or sign up."
            sleep 3
        end
    end
end