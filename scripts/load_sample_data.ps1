# Load sample data into OpenSearch
# Windows PowerShell version

Write-Host "Loading sample data into OpenSearch..." -ForegroundColor Cyan

# Skip SSL certificate validation
add-type @" 
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@ -ErrorAction SilentlyContinue
[System.Net.ServicePointManager]::CertificatePolicy = New-Object 
TrustAllCertsPolicy[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12


# Create Basic Auth header
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:yourStrongPassword123!"))
$headers = @{
    "Authorization" = "Basic $base64Auth"
}


# Create sample_books index
Write-Host "Creating sample_books index..." -ForegroundColor Yellow
$booksMapping = @{
    mappings = @{
        properties = @{
            title = @{ type = "text"; analyzer = "standard" }
            author = @{ type = "text"; analyzer = "standard" }
            genre = @{ type = "keyword" }
            publication_year = @{ type = "integer" }
            description = @{ type = "text" }
            rating = @{ type = "float" }
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "https://localhost:9200/sample_books" `
        -Method Put `
        -Headers $headers `
        -ContentType "application/json" `
        -Body $booksMapping `
        -UseBasicParsing
    Write-Host "Books index created" -ForegroundColor Green
} catch {
    Write-Host "Error creating books index: $_" -ForegroundColor Red
}

# Add sample book documents
Write-Host "Adding sample book documents..." -ForegroundColor Yellow

$books = @(
    @{ title = "The Great Gatsby"; author = "F. Scott Fitzgerald"; genre = "Classic"; publication_year = 1925; description = "A classic American novel set in the Jazz Age"; rating = 4.2 },
    @{ title = "To Kill a Mockingbird"; author = "Harper Lee"; genre = "Classic"; publication_year = 1960; description = "A gripping tale of racial injustice and childhood innocence"; rating = 4.5 },
    @{ title = "1984"; author = "George Orwell"; genre = "Dystopian"; publication_year = 1949; description = "A dystopian social science fiction novel"; rating = 4.4 },
    @{ title = "Pride and Prejudice"; author = "Jane Austen"; genre = "Romance"; publication_year = 1813; description = "A romantic novel of manners"; rating = 4.3 },
    @{ title = "The Catcher in the Rye"; author = "J.D. Salinger"; genre = "Coming-of-age"; publication_year = 1951; description = "A controversial novel about teenage rebellion"; rating = 3.8 }
)


$id = 1
foreach ($book in $books) {
    try {
        $bookJson = $book | ConvertTo-Json
        Invoke-WebRequest -Uri "https://localhost:9200/sample_books/_doc/$id" `
            -Method Post `
            -Headers $headers `
            -ContentType "application/json" `
            -Body $bookJson `
            -UseBasicParsing | Out-Null
        Write-Host "  Added: $($book.title)" -ForegroundColor Gray
        $id++
    } catch {
        Write-Host "  Error adding book: $_" -ForegroundColor Red
    }
}

# Create sample_products index
Write-Host "Creating sample_products index..." -ForegroundColor Yellow
$productsMapping = @{
    mappings = @{
        properties = @{
            name = @{ type = "text"; analyzer = "standard" }
            category = @{ type = "keyword" }
            price = @{ type = "float" }
            description = @{ type = "text" }
            in_stock = @{ type = "boolean" }
            tags = @{ type = "keyword" }
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "https://localhost:9200/sample_products" `
        -Method Put `
        -Headers $headers `
        -ContentType "application/json" `
        -Body $productsMapping `
        -UseBasicParsing
    Write-Host "Products index created" -ForegroundColor Green
} catch {
    Write-Host "Error creating products index: $_" -ForegroundColor Red
}

# Add sample product documents
Write-Host "Adding sample product documents..." -ForegroundColor Yellow

$products = @(
    @{ name = "Wireless Headphones"; category = "Electronics"; price = 99.99; description = "High-quality wireless headphones with noise cancellation"; in_stock = $true; tags = @("audio", "wireless", "electronics") },
    @{ name = "Coffee Maker"; category = "Appliances"; price = 79.99; description = "Programmable coffee maker with thermal carafe"; in_stock = $true; tags = @("kitchen", "coffee", "appliances") },
    @{ name = "Running Shoes"; category = "Sports"; price = 129.99; description = "Lightweight running shoes with excellent cushioning"; in_stock = $false; tags = @("shoes", "running", "sports") },
    @{ name = "Laptop Stand"; category = "Office"; price = 49.99; description = "Adjustable aluminum laptop stand for ergonomic working"; in_stock = $true; tags = @("office", "ergonomic", "laptop") },
    @{ name = "Yoga Mat"; category = "Fitness"; price = 29.99; description = "Non-slip yoga mat perfect for home workouts"; in_stock = $true; tags = @("yoga", "fitness", "exercise") }
)

$id = 1
foreach ($product in $products) {
    try {
        $productJson = $product | ConvertTo-Json
        Invoke-WebRequest -Uri "https://localhost:9200/sample_products/_doc/$id" `
            -Method Post `
            -Headers $headers `
            -ContentType "application/json" `
            -Body $productJson `
            -UseBasicParsing | Out-Null
        Write-Host "  Added: $($product.name)" -ForegroundColor Gray
        $id++
    } catch {
        Write-Host "  Error adding product: $_" -ForegroundColor Red
    }
}
# Refresh indices
Write-Host "Refreshing indices..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "https://localhost:9200/sample_books/_refresh" -Method Post -Headers $headers -UseBasicParsing | Out-Null
    Invoke-WebRequest -Uri "https://localhost:9200/sample_products/_refresh" -Method Post -Headers $headers -UseBasicParsing | Out-Null
    Write-Host "Indices refreshed" -ForegroundColor Green
} catch {
    Write-Host "Error refreshing indices: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Sample data loaded successfully!" -ForegroundColor Green
Write-Host "Available indices:" -ForegroundColor Cyan
Write-Host "  - sample_books (5 documents)"
Write-Host "  - sample_products (5 documents)"
