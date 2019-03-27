require 'sqlite3'
require 'singleton'

# users
# questions
# replies
# question_follows
# question_likes

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users 
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    row = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    # p row > [{"id"=>1, "fname"=>"Phu", "lname"=>"Nguyen"}]
    # p row.class > Array
    Users.new(row.first)
  end


  def self.find_by_name(fname, lname)
    row = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    Users.new(row.first)
  end


  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end


  def authored_questions
    Questions.find_by_author_id(@id)
  end


  def authored_replies
    Reply.find_by_user_id(@id)
  end


  def followed_questions
    QuestionFollows.followed_questions_for_user_id(@id)
  end

end

# CREATE TABLE questions (
#   id INTEGER PRIMARY KEY, 
#   title STRING NOT NULL,
#   body STRING NOT NULL,
#   user_id INTEGER NOT NULL,

#   FOREIGN KEY (user_id) REFERENCES users(id)
# );

class Questions
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end


  def self.find_by_author_id(user_id)
    row = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    result = []
    row.each do |question|
      result << Questions.new(question)
    end
    result
  end

  # def create
  #   raise "error" if @id
  #   QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
  #     INSERT INTO
  #       questions (title, body, user_id)
  #     VALUES
  #       (?, ?, ?)
  #   SQL

  #  @id = QuestionsDatabase.instance.lastrow
  # end

  def author
    Users.find_by_id(@user_id)
  end


  def replies
    Reply.find_by_question_id(@id)
  end


  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

end

#replies
  # id INTEGER PRIMARY KEY,
  # body STRING NOT NULL,
  # question_id INTEGER NOT NULL,
  # parent_reply STRING NOT NULL,
  # user_id INTEGER NOT NULL,

class Reply
  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
  end

  def self.find_by_user_id(user_id)
    row = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    result = []
    row.each do |reply|
      result << Reply.new(reply)
    end
    result
  end

  def self.find_by_question_id(question_id)
    row = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    result = []
    row.each do |reply|
      result << Reply.new(reply)
    end
    result
  end

  def author
    Users.find_by_id(@user_id)
  end

  def question
    row = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Questions.new(row.first)
  end

  def parent_reply
    row = QuestionsDatabase.instance.execute(<<-SQL, @parent_reply)
      SELECT 
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Reply.new(row.first)
  end

  def child_replies
    row = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply = ?
    SQL

    result = []
    row.each do |child|
      result << Reply.new(child)
    end
    result

  end
end


# # CREATE TABLE question_follows (
#   id INTEGER PRIMARY KEY,
#   question_id INTEGER NOT NULL,
#   user_id INTEGER NOT NULL,

#   FOREIGN KEY (question_id) REFERENCES questions(id),
#   FOREIGN KEY (user_id) REFERENCES users(id)
# # );

class QuestionFollows
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.followers_for_question_id(question_id)
    row = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      questionfollows
    JOIN users
      ON questionfollows.user_id = users.id
    WHERE
      questionfollowers.question_id = ?
    SQL
    users = []
    row.each do |user|
      users << Users.new(user)
    end
    users
  end

  def self.followed_questions_for_user_id(user_id)
    row = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questionfollows
      JOIN
        questions
          ON questionfollows.question_id = questions.id
      WHERE
        questionfollows.user_id = ?
    SQL
    
    quests = []
    row.each do |quest|
      quests << Questions.new(quest)
    end
    quests
  end

    def self.most_followed_questions(n)
      row = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
          *
        FROM
          questionfollows
        JOIN questions
          ON questions.id = questionfollows.question_id
        GROUP BY 
          question_id
        ORDER BY
          COUNT(*) DESC
        LIMIT ?

      SQL
      quest = []
      row.each do |quest|
        quest << Question.new(quest)
      end
      quest
    end

end


