with Ada.Text_IO, ada.long_Integer_Text_IO;
use Ada.Text_IO, ada.long_Integer_Text_IO;


procedure Main is
type ArrayOfLongInteger is array(Long_Integer range<>) of Long_Integer;

   arr: ArrayOfLongInteger(1..1000);
   countOfPartOfArray: Long_Integer := 4;

   function calculatePartiralSum (firstIndex, secondIndex : in Long_Integer) return Long_Integer;

   protected Server is
      procedure setResult(Current : in Long_Integer);
      function getResult return Long_Integer;
      entry Wait;

   private
      sum : Long_Integer := 0;
      counterOfPartOfArray : Long_Integer := 0;
   end;

   protected body Server is
      procedure setResult(Current : in Long_Integer) is
      begin
         sum := sum + Current;
         counterOfPartOfArray := counterOfPartOfArray + 1;
      end setResult;

      function getResult return Long_Integer is
      begin
         return sum;
      end getResult;

      entry Wait when counterOfPartOfArray = countOfPartOfArray is
      begin
         null;
      end Wait;
   end Server;

   function calculatePartiralSum (firstIndex, secondIndex : in Long_Integer) return Long_Integer is
      result : Long_Integer := 0;
   begin
      for i in firstIndex .. secondIndex loop
         result := result + arr(i);
      end loop;

      return result;
   end calculatePartiralSum;

   task type TaskCalculatePartiralSum is
      entry beginCalculatePartiralSum (firstIndex, secondIndex : in Long_Integer);
   end;

   task body TaskCalculatePartiralSum is
      firstIndex, secondIndex, result : Long_Integer;
   begin
      accept beginCalculatePartiralSum (firstIndex, secondIndex : Long_Integer) do
         TaskCalculatePartiralSum.firstIndex := firstIndex;
         TaskCalculatePartiralSum.secondIndex := secondIndex;
      end beginCalculatePartiralSum;

      result := calculatePartiralSum(firstIndex, secondIndex);

      Server.setResult(result);
   end TaskCalculatePartiralSum;

   function calculateSum(arr : in ArrayOfLongInteger; length, countOfPartOfArray : in Long_Integer) return Long_Integer is
      firstIndex : Long_Integer := arr'First;
      secondIndex, result, sumOfPartOfArray: Long_Integer;

      lengthOfPartOfArray : Long_Integer := length / countOfPartOfArray;
      tempArray : array (0 .. countOfPartOfArray - 1) of TaskCalculatePartiralSum;
   begin
      for i in tempArray'Range loop
         secondIndex := firstIndex + lengthOfPartOfArray;
         tempArray(i).beginCalculatePartiralSum(firstIndex, secondIndex - 1);
         firstIndex := secondIndex;
      end loop;

      result := result + Server.getResult;

      Server.Wait;

      return result;
   end calculateSum;

begin
   for i in arr'First .. arr'Last loop
      arr(i) := Long_Integer(i);
   end loop;

   Put("Sum is ");
   Put(calculateSum(arr, arr'Length, countOfPartOfArray)'Image);
end Main;
