uses Crt;
//uses System;
uses MatrixMath;

const
  matrixRowsAmount: integer = 3;
  matrixColumnsAmount: integer = 4;

var
  RowIndex: integer;
  ColumnIndex: integer;
  //matrix: array[,] of real;
  //resultMatrix: array[,] of real;
  extendResultMatrix: ExtendMatrix;
  tempMatrix: array[,] of real;
  FuncCoff: array of real;
  
  matrixTransformCount: integer := 1;
  {matrixExample1 := new real[5, 6] (
    (  3.0,  1.0, -4.0,  2.0, -5.0,  9.0),
    (  6.0,  0.0,  1.0, -3.0,  4.0, -5.0),
    (  1.0,  0.0,  1.0, -1.0,  1.0, -1.0),
    (  0.0,  2.0,  6.0, -5.0,  1.0,  4.0),
    (-10.0, -1.0,  2.0,  2.0,  0.0, -3.0)
  );}
  
  //extendMatrixExample1: ExtendMatrix := (
    //baseMatrix: matrixExample1;
    //rowX: new string[5] ('-x1', '-x2', '-x3', '-x4', '-x5');
   // columnX: new string[5] ('x6=', 'x7=', 'x8=', 'f ', 'g ');
  //);
  
  matrixExample4 := new real[7, 8] (
    ( 1.0,  1.0,  1.0,  1.0,  0.0,  0.0,  0.0,  0.0),
    ( 1.0,  1.0, -2.0,  0.0,  1.0,  0.0,  0.0,  0.0),
    ( 2.0,  2.0,  3.0,  0.0,  0.0,  1.0,  0.0,  0.0),
    ( 3.0,  3.0,  2.0,  0.0,  0.0,  0.0,  1.0,  0.0),
    ( 1.0,  2.0,  2.0,  0.0,  0.0,  0.0,  0.0, -1.0),
    ( 0.0,  1.0, -1.0,  0.0,  0.0,  0.0,  0.0,  0.0),
    (-8.0, -9.0, -6.0, -1.0, -1.0, -1.0, -1.0,  1.0)
  );
  
  extendMatrixExample4: ExtendMatrix := (
    baseMatrix: matrixExample4;
    rowX: new string[7] ('-x1', '-x2', '-x3', '-x4', '-x5', '-x6', '-x7');
    columnX: new string[7] ('x8 ', 'x9 ', 'x10 ', 'x11 ', 'x12 ', 'f ', 'g ');
  );
  
procedure printResult();
begin
  Writeln('Результат:');
  Writeln(' ');
      
  // исключаем строки g, f и столбец уравнения, поэтому длина - 3
  var xValues := ArrFill(
    extendResultMatrix.baseMatrix.GetLength(0) + extendResultMatrix.baseMatrix.GetLength(1) - 3,
    0.0
  );
  
  // проход по столбцу
  for var i := 0 to extendResultMatrix.columnX.Length - 3 do
  begin
    var variableName := extendResultMatrix.columnX[i];
    var index := StrToInt(variableName.Substring(1, variableName.Length - 2)) - 1;
    //var columnXIndex := extendResultMatrix.columnX.IndexOf(variableName);
    xValues[index] := extendResultMatrix.baseMatrix[i, 0];
  end;
  
  // ответ
  Write('x  =  ( ');
  for var i := 0 to xValues.Length - 1 do
  begin
    Write(xValues[i]:0:2, ' ');
  end;
  Writeln(')');
  Writeln(' ');
  
  // проверка на искуственные переменные 
  if (xValues.TakeLast(extendResultMatrix.baseMatrix.GetLength(0) - 2).All(x -> x = 0)) then
  begin
    var answer := 0.0;
    for var i := 0 to extendResultMatrix.baseMatrix.ColCount() - 2 do
      answer += -FuncCoff[i] * xValues[i];
    Writeln('F(x) = ', answer:0:2)
  end
  else        
    Writeln('Исходная задача не имеет опорного плана');
end;

begin
  extendResultMatrix := extendMatrixExample4;
  FuncCoff := extendResultMatrix.baseMatrix
    .Row(extendResultMatrix.baseMatrix.GetLength(0) - 2).Skip(1).ToArray();
  
  Writeln('Первоначальная матрица:');
  Writeln('#####################################################################');
  extendResultMatrix.Print();
  Writeln(' ');
  
  while (true) do
  begin
    ColumnIndex := extendResultMatrix.FindColumnIndex();
    
    // ищем отрицательный элемент
    var ColumnElementsNegative := true;
    for var i := 0 to extendResultMatrix.baseMatrix.GetLength(0) - 3 do
    begin
      if (extendResultMatrix.baseMatrix[i, ColumnIndex] > 0) then
      begin
        ColumnElementsNegative := false;
        break;
      end;
    end;
    
    if (ColumnElementsNegative) then
    begin
      Writeln('Нет решений');
      exit;
    end;
    
    
    RowIndex := extendResultMatrix.FindRowIndex(ColumnIndex);
    Writeln('Индекс разрешающего элемента (k, s): (', RowIndex + 1, ', ', ColumnIndex, ')');
    Writeln(' ');
    Writeln('Число разрешающий элемент из матрицы: ', extendResultMatrix.baseMatrix[RowIndex, ColumnIndex]);
    Writeln(' ');
    
    tempMatrix := GaussianElimination(extendResultMatrix.baseMatrix, (RowIndex, ColumnIndex));
    extendResultMatrix.baseMatrix := tempMatrix;
    extendResultMatrix.ChangeRowAndColumn(RowIndex, ColumnIndex - 1);
    Writeln('#####################################################################');
    extendResultMatrix.Print();
    //Writeln('#################################################################');
    Writeln(' ');
    
    if (extendResultMatrix.RowElementsSuccess(
        extendResultMatrix.baseMatrix.GetLength(0) - 1))
    then
      break;
    
    matrixTransformCount += 1;
  end;
  
  while (true) do
  begin    
    // поиск индекса столбца, в котором элемент из строки g равен 0, а из строки f меньше 0. begin
    ColumnIndex := -1;
    for var i := 1 to extendResultMatrix.baseMatrix.GetLength(1) - 1 do
      if (
        (extendResultMatrix.baseMatrix[extendResultMatrix.baseMatrix.GetLength(0) - 1, i] = 0)
        and (extendResultMatrix.baseMatrix[extendResultMatrix.baseMatrix.GetLength(0) - 2, i] < 0)
      ) then
      begin
        ColumnIndex := i;
        break;
      end;
    
    
    if (ColumnIndex > 0) then
    begin
      // ищем отрицательный элемент
      var ColumnElementsNegative := true;
      for var i := 0 to extendResultMatrix.baseMatrix.GetLength(0) - 3 do
      begin
        if (extendResultMatrix.baseMatrix[i, ColumnIndex] > 0) then
        begin
          ColumnElementsNegative := false;
          break;
        end;
      end;
      
      if (ColumnElementsNegative) then
      begin
        Writeln('Нет решений');
        exit;
      end;
      
      
      RowIndex := extendResultMatrix.FindRowIndex(ColumnIndex);
      Writeln('Индекс разрешающего элемента (k, s): (', RowIndex + 1, ', ', ColumnIndex, ')');
      Writeln(' ');
      Writeln('Число разрешающий элемент из матрицы: ', extendResultMatrix.baseMatrix[RowIndex, ColumnIndex]);
      Writeln(' ');
      
      tempMatrix := GaussianElimination(extendResultMatrix.baseMatrix, (RowIndex, ColumnIndex));
      extendResultMatrix.baseMatrix := tempMatrix;
      extendResultMatrix.ChangeRowAndColumn(RowIndex, ColumnIndex - 1);
      Writeln('#####################################################################');
      extendResultMatrix.Print();
      
      matrixTransformCount += 1;
      //Writeln('#################################################################');
      Writeln(' ');
    end
    else
    begin
      printResult();      
      exit;
    end;
  end;
end.