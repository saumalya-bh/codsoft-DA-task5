import pandas as pd
import numpy as np
import os

def run_pipeline():
    print("--- Starting Automated Data Pipeline ---")
    
    # 1. Load Raw Data
    raw_data_path = 'data/superstore.csv'
    if not os.path.exists(raw_data_path):
        print(f"Error: Raw file not found at {raw_data_path}")
        return
        
    df = pd.read_csv(raw_data_path)
    print("Raw data loaded successfully.")

    # 2. Automated Data Cleaning & Transformation
    # Drop exact duplicate rows
    df = df.drop_duplicates()
    
    # Fill missing values in critical columns without inplace on chained indexing
    if 'Category' in df.columns:
        df['Category'] = df['Category'].fillna('Uncategorized')
    if 'Sales' in df.columns:
        df['Sales'] = df['Sales'].fillna(df['Sales'].median())

    # Convert date column to datetime standard
    if 'Order_Date' in df.columns:
        df['Order_Date'] = pd.to_datetime(df['Order_Date'])

    # 3. Calculate Key Business KPIs
    total_revenue = df['Sales'].sum() if 'Sales' in df.columns else 0
    total_orders = df['Order_ID'].nunique() if 'Order_ID' in df.columns else len(df)
    avg_order_value = total_revenue / total_orders if total_orders > 0 else 0

    kpi_summary = pd.DataFrame({
        'KPI Metric': ['Total Revenue', 'Total Orders', 'Average Order Value (AOV)'],
        'Value': [f"${total_revenue:,.2f}", f"{total_orders:,}", f"${avg_order_value:,.2f}"]
    })

    # Category breakdown summary table
    if 'Category' in df.columns and 'Sales' in df.columns:
        category_summary = df.groupby('Category')['Sales'].agg(['sum', 'count']).reset_index()
        category_summary.columns = ['Category', 'Total Sales', 'Order Count']
    else:
        category_summary = pd.DataFrame()

    # 4. Export Cleaned Data and Key Metrics to Excel
    output_path = 'reports/processed_data_summary.xlsx'
    
    # Create reports folder if it doesn't exist
    os.makedirs('reports', exist_ok=True)

    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        kpi_summary.to_excel(writer, sheet_name='KPI Summary', index=False)
        if not category_summary.empty:
            category_summary.to_excel(writer, sheet_name='Category Summary', index=False)
        df.to_excel(writer, sheet_name='Cleaned Data', index=False)

    print(f"Pipeline executed successfully. Output saved to: {output_path}")

if __name__ == "__main__":
    run_pipeline()