# Natural Language Query Examples

Once you have the OpenSearch MCP server configured with your LLM, you can use natural language to interact with OpenSearch. Here are some example queries to get you started:

## Index Management

### Creating Indices
```
Create a new index called "articles" with fields for title, content, author, and publish_date
```

```
Set up an index named "users" with mappings for name, email, age, and registration_date
```

### Viewing Index Information
```
Show me the mapping of the sample_books index
```

```
What indices are available in OpenSearch?
```

```
Get the settings for the sample_products index
```

## Document Operations

### Adding Documents
```
Add a document to the sample_books index with title "Dune" and author "Frank Herbert"
```

```
Insert a new product: name "Gaming Mouse", category "Electronics", price 59.99, in_stock true
```

### Searching Documents
```
Search for books by George Orwell
```

```
Find all products in the Electronics category
```

```
Search for books published after 1950
```

```
Find products that are currently in stock
```

```
Search for books with "classic" in the description
```

## Advanced Queries

### Filtering and Sorting
```
Find books with rating above 4.0, sorted by publication year
```

```
Search for products under $50 in the Fitness category
```

```
Get all books from the 20th century (1901-2000) sorted by rating
```

### Aggregations
```
Show me the average rating of books by genre
```

```
Count how many products we have in each category
```

```
What's the price range of products in our inventory?
```

## Complex Searches

### Multi-field Searches
```
Search for "wireless" in product names or descriptions
```

```
Find books where either the title or author contains "great"
```

### Boolean Queries
```
Find electronics products that are in stock AND cost less than $100
```

```
Search for books that are either classics OR published before 1950
```

## Data Analysis

### Statistical Queries
```
What's the average price of products by category?
```

```
Show me the distribution of book ratings
```

```
Which author has the most books in our collection?
```

### Trend Analysis
```
Show me publication trends by decade for our book collection
```

```
What are the most common tags in our product catalog?
```

## Index Maintenance

### Updating Documents
```
Update the price of the "Wireless Headphones" product to $89.99
```

```
Change the rating of "1984" to 4.6
```

### Deleting Data
```
Delete all products that are out of stock
```

```
Remove the book with ID 3 from the sample_books index
```

## Tips for Better Results

1. **Be Specific**: Include field names when possible
   - ✅ "Search for books where author is 'Jane Austen'"
   - ❌ "Find Jane Austen stuff"

2. **Use Natural Language**: The MCP server understands conversational queries
   - ✅ "Show me all electronics under $100"
   - ✅ "Find cheap electronics"

3. **Combine Operations**: You can chain multiple operations
   - ✅ "Create an index called 'reviews' and add a document with rating 5"

4. **Ask for Explanations**: Request details about what's happening
   - ✅ "Search for books by Orwell and explain the query structure"

## Troubleshooting Queries

If a query doesn't work as expected:

1. **Check Index Names**: Make sure you're referencing the correct index
2. **Verify Field Names**: Use exact field names from your mappings
3. **Check Data Types**: Ensure you're using appropriate data types for comparisons
4. **Start Simple**: Begin with basic queries and add complexity gradually

## Sample Data Available

The demo includes two pre-loaded indices:

### sample_books
- title (text)
- author (text) 
- genre (keyword)
- publication_year (integer)
- description (text)
- rating (float)

### sample_products
- name (text)
- category (keyword)
- price (float)
- description (text)
- in_stock (boolean)
- tags (keyword array)

Try these queries with the sample data to see the MCP integration in action!