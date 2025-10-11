# PowerShell script to update food image URLs in nutrition_exercise_service.dart

# Define the mapping of food names to image URLs
$imageUrlMap = @{
    "Lentils" = "https://images.unsplash.com/photo-1509358271058-acd22cc93898?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Lean Beef (Well-cooked)" = "https://images.unsplash.com/photo-1546833999-b9f581a1996d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Tofu or Tempeh" = "https://images.unsplash.com/photo-1609501676725-7186f73b2c92?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Fresh Vegetables (Carrots, Broccoli)" = "https://images.unsplash.com/photo-1590779033100-9f60a05a013d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Fresh Fruits (Bananas, Apples)" = "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Unsalted Nuts and Seeds" = "https://images.unsplash.com/photo-1566478989037-eec170784d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Fresh Herbs (Basil, Oregano, Thyme)" = "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Dried Beans and Peas (rinsed)" = "https://images.unsplash.com/photo-1599909533980-d905c27c4a8c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Whole Grains (Oats, Quinoa)" = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Lean, Unseasoned Meat/Poultry" = "https://images.unsplash.com/photo-1546833999-b9f581a1996d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Garlic and Onion Powder (No salt added)" = "https://images.unsplash.com/photo-1509358271058-acd22cc93898?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Black Beans" = "https://images.unsplash.com/photo-1562195561-4a7b6b60b56a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Whole Oats (Steel-cut or Rolled)" = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Non-starchy Vegetables (Spinach, Zucchini)" = "https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Berries (Strawberries, Blueberries)" = "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Nuts (Almonds, Walnuts)" = "https://images.unsplash.com/photo-1566478989037-eec170784d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Whole Grain Bread (100% whole wheat)" = "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Raspberries" = "https://images.unsplash.com/photo-1577003833619-76bbd1575a8e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Blackberries" = "https://images.unsplash.com/photo-1498557850523-fd3d118b962e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Chia Seeds" = "https://images.unsplash.com/photo-1517847834756-d7ad0c223bb2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Flaxseeds" = "https://images.unsplash.com/photo-1517847834756-d7ad0c223bb2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Pears (with skin)" = "https://images.unsplash.com/photo-1518977676601-b53f82aba655?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Kidney Beans" = "https://images.unsplash.com/photo-1562195561-4a7b6b60b56a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Artichokes" = "https://images.unsplash.com/photo-1553801090-d0261e2fa7e0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Broccoli" = "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Spinach (Cooked)" = "https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Fortified Breakfast Cereal" = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "White Beans" = "https://images.unsplash.com/photo-1599909533980-d905c27c4a8c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Tofu" = "https://images.unsplash.com/photo-1609501676725-7186f73b2c92?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Blackstrap Molasses" = "https://images.unsplash.com/photo-1571771019784-3ff35f4f4277?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Oysters (Ensure fully cooked)" = "https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Pumpkin Seeds" = "https://images.unsplash.com/photo-1566478989037-eec170784d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Milk (Dairy or Fortified Plant-based)" = "https://images.unsplash.com/photo-1550583724-b2692b85b150?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Plain Yogurt" = "https://images.unsplash.com/photo-1488477181946-6428a0291777?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Cheese (Hard, pasteurized varieties)" = "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Canned Sardines (with bones)" = "https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Tofu (made with calcium sulfate)" = "https://images.unsplash.com/photo-1609501676725-7186f73b2c92?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Kale" = "https://images.unsplash.com/photo-1574316071802-0d684efa7bf5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Calcium-fortified Orange Juice" = "https://images.unsplash.com/photo-1577234449517-af017c2b0a85?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Sesame Seeds/Tahini" = "https://images.unsplash.com/photo-1566478989037-eec170784d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Liver (Limit due to Vitamin A)" = "https://images.unsplash.com/photo-1546833999-b9f581a1996d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Eggs (B12)" = "https://images.unsplash.com/photo-1518492104633-130d0cc84637?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Beef (Well-cooked, B12)" = "https://images.unsplash.com/photo-1546833999-b9f581a1996d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Fortified Grains/Cereals" = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Spinach (Folate)" = "https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Asparagus (Folate)" = "https://images.unsplash.com/photo-1509358271058-acd22cc93898?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Nutritional Yeast (B12)" = "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Black-eyed Peas (Folate)" = "https://images.unsplash.com/photo-1599909533980-d905c27c4a8c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Salmon (Low-mercury choice)" = "https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Walnuts" = "https://images.unsplash.com/photo-1553909489-cd47e0ef937f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Omega-3 Fortified Eggs" = "https://images.unsplash.com/photo-1518492104633-130d0cc84637?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Canned Light Tuna (Limited)" = "https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Hemp Seeds" = "https://images.unsplash.com/photo-1566478989037-eec170784d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Watermelon" = "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Cucumber" = "https://images.unsplash.com/photo-1604977042946-1eecc30f269e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Celery" = "https://images.unsplash.com/photo-1551754655-cd27e38d2076?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Strawberries" = "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Coconut Water (in moderation)" = "https://images.unsplash.com/photo-1520638023360-6def43369781?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Lettuce" = "https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
    "Grapefruit" = "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
}

# Read the file content
$filePath = "nutrition_exercise_service.dart"
$content = Get-Content $filePath -Raw

# Update each empty imageUrl with the corresponding URL
foreach ($foodName in $imageUrlMap.Keys) {
    $pattern = "name: '$foodName',[\s\S]*?imageUrl: '',"
    $replacement = $content -match $pattern
    if ($replacement) {
        $newUrl = $imageUrlMap[$foodName]
        $content = $content -replace "(?<=name: '$foodName',[\s\S]*?)imageUrl: '',", "imageUrl: '$newUrl',"
    }
}

# Write the updated content back to the file
$content | Set-Content $filePath -NoNewline

Write-Host "Image URLs updated successfully!" -ForegroundColor Green