
import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:flutter_leak_find_pc/report/report_leak.dart';

class VariableDeclarationWrap{
  final VariableDeclaration node;
  final TypeAnnotation type;

  VariableDeclarationWrap(this.node, this.type);
}

LineInfo fileLineInfo;

List retainClassList =[];

class LintAstVisitor extends GeneralizingAstVisitor<Map> {
  @override
  Map visitNode(AstNode node) {
    //输出遍历AST Node 节点内容
    node.accept(VariableVisitor());
    return super.visitNode(node);
  }
}

class VariableVisitor extends SimpleAstVisitor<Map> {
  @override
  //成员变量
  Map visitFieldDeclaration(FieldDeclaration node) {

    //变量作用域
    final unit = node.thisOrAncestorOfType<CompilationUnit>();
    TypeAnnotation type = node.fields.type;


    node.fields.variables.forEach((variableNode) {

      _buildVariableReporter(unit, VariableDeclarationWrap(variableNode,type));

    });

    return super.visitFieldDeclaration(node);
  }


  @override
  Map visitVariableDeclarationStatement(VariableDeclarationStatement node) {

    //变量作用域
    final function = node.thisOrAncestorOfType<FunctionBody>();
    TypeAnnotation type = node.variables.type;

    node.variables.variables.forEach((variableNode) {
      _buildVariableReporter(function, VariableDeclarationWrap(variableNode,type));
    });

    return super.visitVariableDeclarationStatement(node);
  }

  @override
  Map visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {

    //变量作用域
    final unit = node.thisOrAncestorOfType<CompilationUnit>();
    TypeAnnotation type = node.variables.type;

    node.variables.variables.forEach((variableNode) {

      _buildVariableReporter(unit, VariableDeclarationWrap(variableNode,type));

    });
    return super.visitTopLevelVariableDeclaration(node);
  }

}

_buildVariableReporter(AstNode container,VariableDeclarationWrap variable ){

  //dispose cancel 分支_buildVariableReporter
  //判断 赋值表达式

  //引用链分支
  if(!_isRtainPathClass(variable.type.toString())) return;

  int lineNum = _getLineNum(variable.node);
  //在引用链中的变量标黄
  ReportLeak.add(lineNum, ReportNodeInfo(1,lineNum,'in retainPath',variable.node.offset,variable.node.end));

  final containerNodes = _traverseNodesInDFS(container);

  var assigmentNodes =  _findVariableAssignments(containerNodes,variable);

  if(assigmentNodes.isNotEmpty){

    int lineNum = _getLineNum(variable.node);
    //对widget引用标红
    ReportLeak.add(lineNum, ReportNodeInfo(2,lineNum,'retain self',variable.node.offset,variable.node.end));

    assigmentNodes.forEach((node) {
      int lineNum = _getLineNum(node);
      ReportLeak.add(lineNum, ReportNodeInfo(2,lineNum,'retain self',node.offset,node.end));
    });
  }

 var methodInvNodes = _findMethodInvocation(containerNodes,variable);

  if(methodInvNodes.isNotEmpty){

    int lineNum = _getLineNum(variable.node);
    //对widget引用标红
    ReportLeak.add(lineNum, ReportNodeInfo(2,lineNum,'retain self',variable.node.offset,variable.node.end));

    methodInvNodes.forEach((node) {
      int lineNum = _getLineNum(node);
      ReportLeak.add(lineNum, ReportNodeInfo(2,lineNum,'retain self',node.offset,node.end));
    });
  }

}

Iterable<AstNode>  _findMethodInvocation(Iterable<AstNode> containerNodes, VariableDeclarationWrap variable){

  return containerNodes.where((n) =>
      n is MethodInvocation
      &&(n.target is PrefixedIdentifier
              && ((n.target as PrefixedIdentifier).prefix.name == variable.node.name.token.lexeme )
          ||(n.target is SimpleIdentifier
              && (n.target as SimpleIdentifier).token.lexeme == variable.node.name.token.lexeme))
      &&n.argumentList.arguments
          .where((e)=>e is NamedExpression || e is ThisExpression || e is SimpleIdentifier)
          .map((e){
        if (e is NamedExpression) {
          return e.expression.toSource();
        }
        else {
          return e.toSource();
        }
      })
          .any((e) => e.contains('this')  || e.contains('context'))
  );

}

//赋值表达式 含有this 和 context
Iterable<AstNode>  _findVariableAssignments(
    Iterable<AstNode> containerNodes, VariableDeclarationWrap variable) {

  return containerNodes.where((n) =>
  n is AssignmentExpression &&
          // Assignment to VariableDeclaration as setter.
      (
          (n.leftHandSide is PropertyAccess &&
          (n.leftHandSide as PropertyAccess).propertyName.token.lexeme == variable.node.name.token.lexeme)
      ||(n.leftHandSide is SimpleIdentifier)&&
          (n.leftHandSide as SimpleIdentifier).token.lexeme == variable.node.name.token.lexeme
      )
      &&
      n.rightHandSide is MethodInvocation &&
      (n.rightHandSide as MethodInvocation).argumentList.arguments
              .where((e)=>e is NamedExpression || e is ThisExpression || e is SimpleIdentifier)
              .map((e){
                if (e is NamedExpression) {
                  return e.expression.toSource();
                }
                else {
                  return e.toSource();
                }
              })
              .any((e) => e.contains('this') || e.contains('context')));
}


//获取所有节点
 Iterable<AstNode> _traverseNodesInDFS(AstNode node) {
    final nodes = <AstNode>{};
    void recursiveCall(node) {
      if (node is AstNode) {
        nodes.add(node);
        node?.childEntities?.forEach(recursiveCall);
      }
    }
    node?.childEntities?.forEach(recursiveCall);
    return nodes;
}

int _getLineNum(AstNode node){

  var line = fileLineInfo.getLocation(node.offset);
  return line.lineNumber;
}

bool _isRtainPathClass(String className){


  return retainClassList.any((element) => className == element);
}


class LintVisitor extends GeneralizingAstVisitor<Map> {
  @override
  Map visitNode(AstNode node) {
    //输出遍历AST Node 节点内容
    node.accept(LintAstVisitor());
    stdout.writeln('------------'+node.runtimeType.toString()+ '-----'+node.toSource());
    return super.visitNode(node);
  }
}

void generate(String content,String retainJson) {
  if (content.isEmpty) {
    stdout.writeln('No file found');
  } else {
    try {
      //初始化
      ReportLeak.clean();
      retainClassList =[];
      List list = jsonDecode(retainJson);
      list.forEach((element) {
        retainClassList.add(element.split('.').first);
      });
      var parseResult = parseString(content: content);
      var compilationUnit = parseResult.unit;
      fileLineInfo = parseResult.lineInfo;
      //遍历AST
      compilationUnit.accept(LintVisitor());
    } catch (e) {
      stdout.writeln('Parse file error: ${e.toString()}');
    }
  }
  return null;
}


