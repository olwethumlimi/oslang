import '../Lexer/types.dart';
import '../app.dart';
import '../parser.dart/parser.dart';
import '../parser.dart/parser_types.dart';

eval(node) {
  switch (node["type"]) {
    case P_NUMBER:
      return node["value"];
    case P_BINARY_EXPRESSION:
      return BINARY_EXPRESSION_HELPER(node);
    default:
      return "errror node ${node}";
  }
}

BINARY_EXPRESSION_HELPER(node) {
  var left_data = node["left_data"];
  var left_node = eval(node["left_node"]);

  var right_data = node["right_data"];
  var right_node = eval(node["right_node"]);
  var op = node["op"];
  if (num.tryParse(left_data["text"].toString()) == false) {
    var error = parser_customizer_error_position(left_data,
        "unsupported operand type(s) for +: '${left_node.runtimeType}' and '${right_node.runtimeType}'");
    errors.add(error);
    return '\0';
  }

  if (num.tryParse(right_data["text"].toString()) == false) {
    var error = parser_customizer_error_position(left_data,
        "unsupported operand type(s) for +: '${left_node.runtimeType}' and '${right_node.runtimeType}'");
    errors.add(error);
    return '\0';
  }

  if (op == L_PLUS) return left_node + right_node;
  if (op == L_MINUS) return left_node - right_node;
  if (op == L_MODULAS) return left_node % right_node;
  if (op == L_DIVIDE) return left_node / right_node;
  if (op == L_TIMES) return left_node * right_node;

  if (op == L_EQ_EQ) return left_node == right_node;
  if (op == L_LESS_EQ) return left_node <= right_node;
  if (op == L_LESS_THAN) return left_node < right_node;
  if (op == L_GREATER_EQ) return left_node >= right_node;
  if (op == L_GREATER_THAN) return left_node > right_node;
  if (op == L_NOT_EQ) return left_node != right_node;

  return "errror node operator ${node["op"]}";
}
