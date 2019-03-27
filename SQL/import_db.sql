DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;
PRAGMA foreign_keys = ON;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname STRING NOT NULL,
  lname STRING NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY, 
  title STRING NOT NULL,
  body STRING NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body STRING NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply STRING NOT NULL,
  user_id INTEGER NOT NULL,


  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) references questions(id)
);

INSERT INTO users (fname, lname)
VALUES 
  ('Phu', 'Nguyen'),
  ('Josh', 'Weisman');

INSERT INTO questions (title, body, user_id)
VALUES 
  ('Where are the hot singles in my area?', 'I''ve been in SF for three weeks and still no hot singles.', 2),
  ('Why the f*** haven''t you installed Magnet bro?', 'You gotta optimize your workflow.', 1);

-- INSERT INTO replies
-- VALUES
--   (1, 'Have you been to the Tenderloin?', 1, NULL, 1),
--   (2, 'It''s on the App Store.', 2, NULL, 2);

-- INSERT INTO replies
-- VALUES
--   (1, 'Have you been to the Tenderloin?', (SELECT id FROM questions WHERE body = 'Where are the hot singles in my area?'),)