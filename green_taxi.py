import click
import requests
import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path


def download_file(url: str, output_path: Path):
    """
    Download file if it does not already exist
    """
    if output_path.exists():
        print(f"📁 {output_path.name} already exists, skipping download")
        return

    print(f"⬇️ Downloading {url}")
    response = requests.get(url)
    response.raise_for_status()

    output_path.write_bytes(response.content)
    print("✅ Download complete")

@click.command()
@click.option('--pg-user', default='root', help="Postgres username")
@click.option('--pg-password', default='root', help="Postgres password")
# Use container name and internal port as defaults for Docker
@click.option('--pg-host', default='taxi_ingestion_db', help="Postgres hostname (container name inside Docker)")
@click.option('--pg-port', default=5432, help="Postgres port (internal port inside Docker)")
@click.option('--pg-db', default='taxi_db', help="Postgres database name")
@click.option(
    '--url',
    default='https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet',
    help='URL to green taxi parquet file'
)
@click.option(
    '--table',
    default='green_taxi_table',
    help='Target table name'
)
def main(pg_user, pg_password, pg_host, pg_port, pg_db, url, table):
    """
    Download and ingest green taxi parquet data into Postgres
    """

    file_path = Path(url.split('/')[-1])

    download_file(url, file_path)

    print(f"📥 Reading parquet file: {file_path}")
    df = pd.read_parquet(file_path)

    engine = create_engine(
        f'postgresql://{pg_user}:{pg_password}@{pg_host}:{pg_port}/{pg_db}'
    )

    print(f"🗄 Writing data to table: {table}")
    df.to_sql(
        name=table,
        con=engine,
        if_exists='replace',
        index=False,
        method='multi',
        chunksize=100_000
    )

    print("✅ Green taxi ingestion finished")


if __name__ == '__main__':
    main()
