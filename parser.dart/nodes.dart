import 'parser_types.dart';

NUMBER_NODE(value) => {"type": P_NUMBER, "value": value};
ERROR_NODE(value) => {"type": P_ERROR, "value": value};
BINARY_EXPRESSION_NODE(left_data, left_node, op, right_data, right_node) => {
      "left_data": left_data,
      "left_node": left_node,
      "op": op,
      "right_data": right_data,
      "right_node": right_node,
      "type": P_BINARY_EXPRESSION
    };
