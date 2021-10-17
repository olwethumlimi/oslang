import 'types.dart';

var FILE_TEXT = "";
var TEXT_LINES;
var FILE_PATH = "";
var pos = 0;
var line = 1;
var LEX_CHAR_POS = 0;
var NEWLINE_CHECKER = "";

TokenEOF(type, text, line, pos, path) =>
    {"type": type, "text": text, "line": line, "pos": pos, "path": path};

Token(type, text, line, pos, error) => {
      "type": type,
      "text": text,
      "line": line,
      "pos": pos,
      "path": FILE_PATH,
      "error": error
    };

// reset the lexer for a new file
reset_lexer(path, text, lines) {
  FILE_TEXT = text + "\n";
  TEXT_LINES = lines;
  FILE_PATH = path;
  NEWLINE_CHECKER = "";
  LEX_CHAR_POS = 0;
  pos = 0;
  line = 1;
}

customizer_error_position(position) {
  var str = TEXT_LINES[line - 1].toString();
  var store_text = "";
  var store_arrow = "";

  for (var i = 0; i < str.length; i++) {
    store_text += str[i];
    if (position == i) store_arrow += "^";
    if (position - 1 == i)
      store_arrow += "^";
    else
      store_arrow += " ";
  }

  var text = store_text + "\n" + store_arrow;
  return text;
}

lexer_current() =>
    LEX_CHAR_POS < FILE_TEXT.length ? FILE_TEXT[LEX_CHAR_POS] : L_EOF_LEXER;

lexer_lookAhead() => LEX_CHAR_POS + 1 < FILE_TEXT.length
    ? FILE_TEXT[LEX_CHAR_POS + 1]
    : L_EOF_LEXER;
lexer_next_char() {
  LEX_CHAR_POS++;
  pos++;
  NEWLINE_CHECKER += lexer_current();
}

lexer_one_step(type, text) {
  pos = pos;
  lexer_next_char();
  return Token(type, text, line, pos, "");
}

lexer_double_step(type, text) {
  pos = pos;
  lexer_next_char();
  lexer_next_char();
  return Token(type, text, line, pos, "");
}

lexer_tokenizer() {
  switch (lexer_current()) {
    case ' ':
    case '\t':
    case '\b':
    case '\r':
      return lexer_one_step(L_SPECIAL, "<special_characters>");
    case '\n':
      return lexer_newLine();
  }

  //operators
  switch (lexer_current()) {
    case '+':
      return lexer_one_step(L_PLUS, lexer_current());
    case '-':
      return lexer_one_step(L_MINUS, lexer_current());
    case '*':
      return lexer_one_step(L_TIMES, lexer_current());
    case '/':
      return lexer_one_step(L_DIVIDE, lexer_current());
    case '%':
      return lexer_one_step(L_MODULAS, lexer_current());
  }
  switch (lexer_current() + lexer_lookAhead()) {
    case "!=":
        return lexer_double_step(L_NOT_EQ, "!=");
    case "==":
      return lexer_double_step(L_EQ_EQ, "==");
    case "<=":
      return lexer_double_step(L_LESS_EQ, "<=");
    case ">=":
      return lexer_double_step(L_GREATER_EQ, ">=");
  }
  
  if (lexer_current() == "=" && lexer_lookAhead() != "=")
    return lexer_one_step(L_EQ_TO, "=");
  if (lexer_current() == ">" && lexer_lookAhead() != "=")
    return lexer_one_step(L_GREATER_THAN, ">");
  if (lexer_current() == "<" && lexer_lookAhead() != "=")
    return lexer_one_step(L_LESS_THAN, "<");

  if (isNumeric(lexer_current())) return lexer_number();

  return lexer_error();
}

lexer_number() {
  var str = "";
  pos = pos;
  var dot = 0;

  while (isNumeric(lexer_current()) || lexer_current() == '.') {
    str += lexer_current();
    if (lexer_current() == '.') dot++;
    lexer_next_char();
  }
  var error = customizer_error_position(pos);
  if (str.endsWith("."))
    return Token(
        L_ERROR, str, line, pos, "(${line}:${pos}) invalid decimal\n${error}");
  if (str.startsWith("."))
    return Token(
        L_ERROR, str, line, pos, "(${line}:${pos}) invalid decimal\n${error}");
  if (dot > 1)
    return Token(
        L_ERROR, str, line, pos, "(${line}:${pos}) invalid decimal\n${error}");
  return Token(L_NUMBER, num.parse(str), line, pos, "");
}

lexer_newLine() {
  var txt = NEWLINE_CHECKER.trim();

  if (txt.length == 0) {
    var tok = Token(L_EMPTY_NEWLINE, "<empty newline>", line, pos, "");
    NEWLINE_CHECKER = "";
    lexer_next_char();
    line++;
    pos = 0;
    return tok;
  }
  var tok = Token(L_NEWLINE, "<newline>", line, pos, "");
  NEWLINE_CHECKER = "";
  lexer_next_char();
  line++;
  pos = 0;
  return tok;
}

lexer_error() {
  var str = lexer_current();
  pos = pos;
  var error = customizer_error_position(pos);
  lexer_next_char();

  return Token(L_ERROR, str, line, pos,
      "(${line}:${pos}) Unexpected character\n${error}");
}
