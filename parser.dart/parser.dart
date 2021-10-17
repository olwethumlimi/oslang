import '../Lexer/types.dart';
import '../app.dart';
import 'nodes.dart';
import 'parser_types.dart';
import "package:win32/win32.dart";

var P_POS = 0;
var PARSER_FILE_LINES;
parser_file_lines(lines) {
  PARSER_FILE_LINES = lines;
}

parser_customizer_error_position(token, message) {
  var position = token["pos"];
  var line = token["line"];
  var str = PARSER_FILE_LINES[line - 1].toString();
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

  var text =
      "(${line}:${position}) ${message}\n" + store_text + "\n" + store_arrow;
  ;

  return text;
}

parser_current_type() => P_POS < tokens.length
    ? tokens[P_POS]["type"]
    : tokens[tokens.length - 1]["type"];

parser_current_value() => P_POS < tokens.length
    ? tokens[P_POS]["text"]
    : tokens[tokens.length - 1]["text"];

parser_current_token() =>
    P_POS < tokens.length ? tokens[P_POS] : tokens[tokens.length - 1];
parser_next_token() {
  P_POS++;
}

factor() {
  var token = parser_current_token();
  var type = parser_current_type();
  var value = parser_current_value();
  if (type == L_NUMBER) {
    parser_next_token();
    return NUMBER_NODE(value);
  } else {
    var error = parser_customizer_error_position(token, "unexpected type");
    errors.add(error);
    return ERROR_NODE(parser_current_token());
  }
}

term() {
  var left_data = parser_current_token();
  var left_node = factor();
  var op = parser_current_type();
  while (op == L_TIMES || op == L_DIVIDE || op == L_MODULAS) {
    var op_value = parser_current_value();
    parser_next_token();

    var right_data = parser_current_token();
    var right_node = factor();

    if (right_node["type"] == P_ERROR) {
      var error = parser_customizer_error_position(
          parser_current_token(), "invalid  ${op_value} expression");
      // errors.add(error);
      return ERROR_NODE(parser_current_token());
    }

    left_node = BINARY_EXPRESSION_NODE(
        left_data, left_node, op, right_data, right_node);
    op = parser_current_type();
  }
  return left_node;
}

expression() {
  var left_data = parser_current_token();
  var left_node = term();
  var op = parser_current_type();
  while (op == L_PLUS || op == L_MINUS) {
    var op_value = parser_current_value();
    parser_next_token();

    var right_data = parser_current_token();

    var right_node = term();

    if (right_node["type"] == P_ERROR) {
      var error = parser_customizer_error_position(
          parser_current_token(), "invalid ${op_value} expression");
      // errors.add(error);
      return ERROR_NODE(parser_current_token());
    }

    left_node = BINARY_EXPRESSION_NODE(
        left_data, left_node, op, right_data, right_node);
    op = parser_current_type();
  }
  return left_node;
}

logic() {
  var left_data = parser_current_token();
  var left_node = expression();
  var op = parser_current_type();
  while (op == L_EQ_EQ ||
      op == L_LESS_THAN ||
      op == L_LESS_EQ ||
      op == L_NOT_EQ ||
      op == L_GREATER_EQ ||
      op == L_GREATER_THAN) {
    var op_value = parser_current_value();
    parser_next_token();

    var right_data = parser_current_token();

    var right_node = expression();

    if (right_node["type"] == P_ERROR) {
      var error = parser_customizer_error_position(
          parser_current_token(), "invalid ${op_value} expression");
      // errors.add(error);
      return ERROR_NODE(parser_current_token());
    }

    left_node = BINARY_EXPRESSION_NODE(
        left_data, left_node, op, right_data, right_node);
    op = parser_current_type();
  }
  return left_node;
}
