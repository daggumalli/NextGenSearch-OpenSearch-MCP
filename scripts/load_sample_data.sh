#!/bin/bash

# Load sample data into OpenSearch
set -e

echo "📊 Loading sample data into OpenSearch..."

# Wait for OpenSearch to be ready
echo "⏳ Ensuring OpenSearch is ready..."
max_attempts=10
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -k -u admin:yourStrongPassword123! https://localhost:9200 &> /dev/null; then
        break
    fi
    echo "⏳ Waiting for OpenSearch... (attempt $attempt/$max_attempts)"
    sleep 5
    ((attempt++))
done

# Create sample books index
echo "📚 Creating sample_books index..."
curl -k -X PUT "https://localhost:9200/sample_books" \
  -u admin:yourStrongPassword123! \
  -H "Content-Type: application/json" \
  -d '{
    "mappings": {
      "properties": {
        "title": {
          "type": "text",
          "analyzer": "standard"
        },
        "author": {
          "type": "text",
          "analyzer": "standard"
        },
        "genre": {
          "type": "keyword"
        },
        "publication_year": {
          "type": "integer"
        },
        "description": {
          "type": "text"
        },
        "rating": {
          "type": "float"
        }
      }
    }
  }'

echo ""

# Add sample book documents
echo "📖 Adding sample book documents..."

books=(
  '{"title": "The Great Gatsby", "author": "F. Scott Fitzgerald", "genre": "Classic", "publication_year": 1925, "description": "A classic American novel set in the Jazz Age", "rating": 4.2}'
  '{"title": "To Kill a Mockingbird", "author": "Harper Lee", "genre": "Classic", "publication_year": 1960, "description": "A gripping tale of racial injustice and childhood innocence", "rating": 4.5}'
  '{"title": "1984", "author": "George Orwell", "genre": "Dystopian", "publication_year": 1949, "description": "A dystopian social science fiction novel", "rating": 4.4}'
  '{"title": "Pride and Prejudice", "author": "Jane Austen", "genre": "Romance", "publication_year": 1813, "description": "A romantic novel of manners", "rating": 4.3}'
  '{"title": "The Catcher in the Rye", "author": "J.D. Salinger", "genre": "Coming-of-age", "publication_year": 1951, "description": "A controversial novel about teenage rebellion", "rating": 3.8}'
)

for i in "${!books[@]}"; do
  curl -k -X POST "https://localhost:9200/sample_books/_doc/$((i+1))" \
    -u admin:yourStrongPassword123! \
    -H "Content-Type: application/json" \
    -d "${books[$i]}"
  echo ""
done

# Create sample products index
echo "🛍️  Creating sample_products index..."
curl -k -X PUT "https://localhost:9200/sample_products" \
  -u admin:yourStrongPassword123! \
  -H "Content-Type: application/json" \
  -d '{
    "mappings": {
      "properties": {
        "name": {
          "type": "text",
          "analyzer": "standard"
        },
        "category": {
          "type": "keyword"
        },
        "price": {
          "type": "float"
        },
        "description": {
          "type": "text"
        },
        "in_stock": {
          "type": "boolean"
        },
        "tags": {
          "type": "keyword"
        }
      }
    }
  }'

echo ""

# Add sample product documents
echo "📦 Adding sample product documents..."

products=(
  '{"name": "Wireless Headphones", "category": "Electronics", "price": 99.99, "description": "High-quality wireless headphones with noise cancellation", "in_stock": true, "tags": ["audio", "wireless", "electronics"]}'
  '{"name": "Coffee Maker", "category": "Appliances", "price": 79.99, "description": "Programmable coffee maker with thermal carafe", "in_stock": true, "tags": ["kitchen", "coffee", "appliances"]}'
  '{"name": "Running Shoes", "category": "Sports", "price": 129.99, "description": "Lightweight running shoes with excellent cushioning", "in_stock": false, "tags": ["shoes", "running", "sports"]}'
  '{"name": "Laptop Stand", "category": "Office", "price": 49.99, "description": "Adjustable aluminum laptop stand for ergonomic working", "in_stock": true, "tags": ["office", "ergonomic", "laptop"]}'
  '{"name": "Yoga Mat", "category": "Fitness", "price": 29.99, "description": "Non-slip yoga mat perfect for home workouts", "in_stock": true, "tags": ["yoga", "fitness", "exercise"]}'
)

for i in "${!products[@]}"; do
  curl -k -X POST "https://localhost:9200/sample_products/_doc/$((i+1))" \
    -u admin:yourStrongPassword123! \
    -H "Content-Type: application/json" \
    -d "${products[$i]}"
  echo ""
done

# Refresh indices
echo "🔄 Refreshing indices..."
curl -k -X POST "https://localhost:9200/sample_books/_refresh" -u admin:yourStrongPassword123!
curl -k -X POST "https://localhost:9200/sample_products/_refresh" -u admin:yourStrongPassword123!

echo ""
echo "✅ Sample data loaded successfully!"
echo "📊 Available indices:"
echo "  • sample_books (5 documents)"
echo "  • sample_products (5 documents)"