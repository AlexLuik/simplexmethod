unit MatrixMath;

interface

type ExtendMatrix = record
  baseMatrix: array[,] of real;
  rowX: array of string;
  columnX: array of string;
  public
    constructor Create(
      baseMatrix: array[,] of real;
      rowX: array of string;
      columnX: array of string
    );
    begin
      Self.baseMatrix := baseMatrix;
      Self.rowX := rowX;
      Self.columnX := columnX;
    end;
    
    function FindRowIndex(ColumnIndex: integer): integer;
    function FindColumnIndex(): integer;
    function RowElementsSuccess(rowIndex: integer): boolean;
    
    procedure GaussianElimination(Indexes: (integer, integer));
    procedure DeleteColumn(index: integer);
    procedure ChangeRowAndColumn(rowXIndex: integer; columnXIndex: integer);
    procedure Print;
    
end;


function findNoZeroElementIndex(matrix: array[,] of real): (integer, integer);
function GaussianElimination(
  matrix: array[,] of real;
  ElementIndexes: (integer, integer)
): array[,] of real;
function copyMatrix(matrix: array[,] of real): array[,] of real;
function rowSum(matrix: array[,] of real; row: integer): real;
function det(
  matrix: array[,] of real;
  topRow: integer;
  bottomRow: integer;
  leftColumn: integer;
  rightColumn: integer
): real;
function deleteColumn(matrix: array[,] of real; column: integer): array[,] of real;
procedure ChangeRow(matrix: array[,] of real; row1, row2: integer; column: integer);
function rank(matrix: array[,] of real): integer;
//procedure printAnswer(matrix: ExtendedMatrix);

implementation

function ExtendMatrix.FindColumnIndex(): integer;
var
  currentElement: real;
  maxAbsElement: real := 0.0;
  absElement: real := 0.0;
  lastRowIndex: integer := self.baseMatrix.GetLength(0) - 1;
begin
  for var i := 1 to self.baseMatrix.GetLength(1) - 1 do
  begin
    currentElement := self.baseMatrix[lastRowIndex, i];
    if (currentElement < 0) then
    begin
      absElement := Abs(currentElement);
      if (absElement > maxAbsElement) then
      begin  
        maxAbsElement := absElement;
        Result := i;
      end;       
    end;     
  end;
end;

function ExtendMatrix.FindRowIndex(ColumnIndex: integer): integer;
var
  currentElement: real := 0;
  minDivisionResult: real := MaxReal;
  divisionResult: real := 0;
begin
  for var i := 0 to self.baseMatrix.GetLength(0) - 3 do
  begin
    currentElement := self.baseMatrix[i, ColumnIndex];
    if (currentElement <= 0) then
      continue;
    
    divisionResult := self.baseMatrix[i, 0] / currentElement;
    if (divisionResult < minDivisionResult) then
    begin
      minDivisionResult := divisionResult;
      Result := i;
    end;
  end;
end;

function ExtendMatrix.RowElementsSuccess(rowIndex: integer): boolean;
begin
  Result := true;
  for var i := 1 to self.baseMatrix.GetLength(1) - 1 do
  begin
    if (self.baseMatrix[rowIndex, i] < 0) then
    begin
      Result := false;
      break;
    end;
  end;
end;

procedure ExtendMatrix.GaussianElimination(Indexes: (integer, integer));
var
  Row, Column: integer;
  piv: real;
begin
  (Row, Column) := Indexes;
  Column += 1; // первый столбец содержит левую часть уравнения
  piv := self.baseMatrix[Row, Column];
  var newMatrix := new real[Length(self.baseMatrix, 0) - 1, Length(self.baseMatrix, 1) - 1];
  
  // заполнение всей матрицы значениями 1 / разр-ий эл-т * определитель
  for var i := 0 to Length(self.baseMatrix, 0) - 1 do
    for var j := 0 to Length(self.baseMatrix, 1) - 1 do
      newMatrix[i,j] := det(self.baseMatrix, i, Row, j, Column) / piv;

  // заполненить строки                     
  for var i := 0 to Length(self.baseMatrix, 1) - 1 do
    newMatrix[Row, i] := self.baseMatrix[Row, i] / piv;
  
  // заполненить столбцы
  for var i := 0 to Length(self.baseMatrix, 0) - 1 do
    newMatrix[i, Column] := -self.baseMatrix[i, Column] / piv;
  
  // вычисление элемента для разрешающего элемента
  newMatrix[Row, Column] := 1 / piv;
  
  self.baseMatrix := newMatrix;
end;

procedure ExtendMatrix.DeleteColumn(index: integer);
begin
  
end;

procedure ExtendMatrix.ChangeRowAndColumn(rowXIndex: integer; columnXIndex: integer);
var
  newRowValue: string;
begin
  newRowValue := '-' + self.columnX[rowXIndex].Substring(0, self.columnX[rowXIndex].Length - 1);  
  self.columnX[rowXIndex] := self.rowX[columnXIndex].Substring(1) + ' ';
  self.rowX[columnXIndex] := newRowValue;
end;

procedure ExtendMatrix.Print;
var charSpace: integer := 7;
begin
  Write('   ':charSpace, '   ', '1':charSpace, '   ');
  foreach var val in self.rowX do
    Write(val:charSpace);
  Writeln('   ');
  for var i := 0 to self.baseMatrix.GetLength(0) - 1 do
  begin
    Write(self.columnX[i]:charSpace, '   ');
    Write(self.baseMatrix[i, 0]:charSpace:2, '   ');
    for var j := 1 to Length(self.baseMatrix, 1) - 1 do
      Write(self.baseMatrix[i, j]:charSpace:2);
    Writeln();
  end;
end;

function findNoZeroElementIndex(matrix: array[,] of real): (integer, integer);
begin
  for var i := 0 to Length(matrix, 0) - 1 do
    for var j := 0 to Length(matrix, 1) - 1 do
      if (matrix[i,j] <> 0.0) then
      begin
        Result := (i, j);
        exit;
      end;       
end;

function gaussianElimination(
  matrix: array[,] of real;
  ElementIndexes: (integer, integer)
): array[,] of real;
var
  ElementRow: integer;
  ElementColumn: integer;
  Element: real;
  accuracyNum: real := 0.000001;
begin
  Result := new real[Length(matrix, 0), Length(matrix, 1)];
  (ElementRow, ElementColumn) := ElementIndexes;
  Element := matrix[ElementRow, ElementColumn];
  
  // заполнение всей матрицы значениями 1 / разр. эл-т * определитель
  for var i := 0 to Length(matrix, 0) - 1 do
    for var j := 0 to Length(matrix, 1) - 1 do
      Result[i,j] := det(matrix, i, ElementRow, j, ElementColumn) / Element;

  // заполнение строки                     
  for var i := 0 to Length(matrix, 1) - 1 do
    Result[ElementRow, i] := matrix[ElementRow, i] / Element;
  
  // заполнение столбца
  for var i := 0 to Length(matrix, 0) - 1 do
    Result[i, ElementColumn] := -matrix[i, ElementColumn] / Element;
  
  // вычисление элемента на месте разрешающего элемента
  Result[ElementRow, ElementColumn] := 1 / Element;
  
  // округление
  for var i := 0 to Result.GetLength(0) - 1 do
    for var j := 0 to Result.GetLength(1) - 1 do
      if ((Result[i, j] < accuracyNum) and (Result[i, j] > -accuracyNum)) then
        Result[i, j] := 0;
end;

function copyMatrix(matrix: array[,] of real): array[,] of real;
var
  rowsAmount := matrix.GetLength(0);
  columnsAmount := matrix.GetLength(1);
begin
  Result := new real[rowsAmount, columnsAmount];
  for var i := 0 to rowsAmount - 1 do
    for var j := 0 to columnsAmount - 1 do
      Result[i,j] := matrix[i,j];
end;

function rowSum(matrix: array[,] of real; row: integer): real;
begin
  Result := 0;
  for var i := 0 to matrix.GetLength(1) - 1 do
    Result += matrix[row, i];
end;

function det(
  matrix: array[,] of real;
  topRow: integer;
  bottomRow: integer;
  leftColumn: integer;
  rightColumn: integer
): real;
begin
  Result := matrix[topRow, leftColumn] * matrix[bottomRow, rightColumn] -
            matrix[topRow, rightColumn] * matrix[bottomRow, leftColumn];         
end;

function deleteColumn(matrix: array[,] of real; column: integer): array[,] of real;
begin
  Result := new real[matrix.GetLength(0), matrix.GetLength(1) - 1];
  
  for var i := 0 to matrix.GetLength(0) - 1 do
    for var j := 0 to matrix.GetLength(1) - 2 do
      if (j >= column) then
        Result[i, j] := matrix[i, j + 1]
      else
        Result[i, j] := matrix[i, j];
end;

procedure ChangeRow(matrix: array[,] of real; row1, row2: integer; column: integer);
var
  temp: real;
begin
  for var i := 0 to column do
  begin
    temp := matrix[row1,i];
    matrix[row1,i] := matrix[row2,i];
    matrix[row2,i] := temp;
  end;
end;

function rank(matrix: array[,] of real): integer;
var
  rowsAmount := matrix.GetLength(0);
  columnsAmount := matrix.GetLength(1);
begin
  var rank := Min(rowsAmount, columnsAmount);
  
  var row := 0;
  while (row < rank) do
  begin
    // Диагональный элемент не равен 0
    if (matrix[row,row] <> 0) then
    begin
      for var col := 0 to rowsAmount - 1 do
        if (col <> row) then
        begin
          var mult := matrix[col,row] / matrix[row,row];
          for var i := 0 to rank do
            matrix[col,i] -= mult * matrix[row,i];
        end;
        
      row += 1;
    end
    else
    begin
      var reduce := true;
      
      for var i := row + 1 to rowsAmount - 1 do
        if (matrix[i,row] <> 0) then
        begin
          ChangeRow(matrix, row, i, rank);
          reduce := false;
          break;
        end;
        
      if (reduce) then
      begin
        rank -= 1;
        
        for var i := 0 to rowsAmount - 1 do
          matrix[i,row] := matrix[i,rank];
      end;
    end
  end;
  
  Result := rank;
end;

{procedure printAnswer(matrix: ExtendedMatrix);
var
  currentSymbolAscii := 97;
  rootSymbols: array of char;
begin
  rootSymbols := new char[matrix.rowX.Length];
  for var i := 0 to matrix.rowX.Length - 1 do
  begin
    rootSymbols[i] := char(currentSymbolAscii + i);
    Writeln(matrix.rowX[i].Substring(1), '= ', rootSymbols[i]);
  end;
  for var i := 0 to matrix.columnX.Length - 1 do
    if (matrix.columnX[i] <> '0=') then
    begin
      Write(matrix.columnX[i], ' ', matrix.baseMatrix[i, 0], ' ');
      for var j := 1 to matrix.baseMatrix.GetLength(1) - 1 do
      begin
        var matrixElement := -matrix.baseMatrix[i, j];
        if (matrixElement = -1) then
          Write('-')
        else
          Write(matrixElement);
        Write(rootSymbols[j - 1], ' ');
      end;
      Writeln();
    end;
end;} 
end.