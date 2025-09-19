📊 Crypto Analytics with PostgreSQL

This project focuses on building a relational database for Crypto Analytics in PostgreSQL using three synthetic datasets: members, prices, and transactions. The database has been structured to reflect a simplified version of a real-world crypto trading platform, where members interact with market prices through recorded transactions.

The members dataset contains information about users such as their unique IDs, names, and regions, forming the backbone of user-related analysis. The prices dataset provides historical cryptocurrency prices, records, including open, close, high, low, and volume for multiple crypto symbols across different dates. The transactions dataset links members with crypto activity by recording details such as transaction IDs, member IDs, symbols, transaction dates, quantities, and amounts. Together, these datasets create a connected framework that supports in-depth trading analytics.

The project workflow begins with generating synthetic data, cleaning and validating the records, and importing them into PostgreSQL. A database named crypto_analytics was created, and appropriate tables were designed with primary and foreign key relationships to ensure referential integrity between members, prices, and transactions. Data was imported using PostgreSQL’s \copy functionality, making it ready for querying and analysis.

The analytical phase explores SQL queries ranging from basic to intermediate levels. These queries cover essential use cases such as counting members by region, analyzing average daily price movements, identifying the most traded cryptocurrencies, evaluating transaction volumes over time, and calculating portfolio performance metrics. Intermediate-level queries further apply joins, aggregations, and window functions to simulate real-world reporting scenarios often used in crypto exchanges and financial dashboards.

Through this project, I gained hands-on experience in designing a relational database, importing and managing structured data, and writing SQL queries tailored to business-focused crypto analytics. This work demonstrates practical skills in database management and analytical problem-solving while also setting a strong foundation for building dashboards in visualization tools like Power BI or Tableau.

