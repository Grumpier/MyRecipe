# MyRecipe

Bread making program - Based on Bread Calculator from Foodgeek

Logic: Hydration: this value is always a % of the solid weight component of the item in question. For example, for an entire recipe that has 2000 grams of solid material and 1000 grams of fluid, the hydration would be 50%. When adding an ingredient of type "Starter", the hydration is a attribute value (saved as a string) that represents the %. In the ingredient table, the % is always 100 but when the ingredient is added to the recipe list, the program should prompt for the hydration percentage and store that value with the saved ingredient.

In listing ingredients in a recipe, each item includes a % that means the following:
    for flours it is the % of total flour weight
    for fluids and starter it is the % of total flour weight
    - what about other types???
    
The total box shows:
    flour total weight along with (???? g from starter)
    fluid total weight along with (????g from starter)
    show starter as ?????
    innoculation: starter weight/non-starter flour weight
    hydration: fluid weight/flour weight
    
PROGRAMMING TO DO
Problem - sometimes when adding a new recipe the prior recipe is getting overwritten - might be that using -1 for recipe index for a new recipe is the problem - is -1 the Swift index for last item???

 Also allow drag up and down to reorder recipe lines.

Delete an ingredient

Delete a section

Alphabetize ingredients in recipe line picker

In add new ingredient, if ingredient name is empty and type is selected, copy type name to ingredient name

Try creating a new integer type called Fat (and any other properties that are used by calculator) to enable identifying the fat properties of any ingredient in a recipe list. Calculator functions can then search for all ingredients with properties of this type to total up fat content.



 
 
 
 

