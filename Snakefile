from os import path

PROJECT_NAME = "greenspace-accessibility-sabadell"
CODE_DIR = "greenspace_accessibility_sabadell"
PYTHON_VERSION = "3.10"

NOTEBOOKS_DIR = "notebooks"
NOTEBOOKS_OUTPUT_DIR = path.join(NOTEBOOKS_DIR, "output")

DATA_DIR = "data"
DATA_RAW_DIR = path.join(DATA_DIR, "raw")
DATA_INTERIM_DIR = path.join(DATA_DIR, "interim")
DATA_PROCESSED_DIR = path.join(DATA_DIR, "processed")


# 0. conda/mamba environment -----------------------------------------------------------
rule create_environment:
    shell:
        "mamba env create -f environment.yml"


rule register_ipykernel:
    shell:
        "python -m ipykernel install --user --name {PROJECT_NAME} --display-name"
        " 'Python ({PROJECT_NAME})'"


# 1. get spatial extent ----------------------------------------------------------------
SPATIAL_EXTENT_IPYNB_FILENAME = "01-spatial-extent.ipynb"
# ACHTUNG: for some reason, the `Sabadell` query returns a different boundary (i.e.,
# Badia del Vallès), so we use the osmid instead
# NOMINATIM_QUERY = "Sabadell"
NOMINATIM_QUERY = "R344202"
BUFFER_DIST = 1000
SPATIAL_EXTENT_GPKG = path.join(DATA_RAW_DIR, "spatial-extent.gpkg")


rule spatial_extent:
    input:
        notebook=path.join(NOTEBOOKS_DIR, SPATIAL_EXTENT_IPYNB_FILENAME),
    params:
        nominatim_query=NOMINATIM_QUERY,
        buffer_dist=BUFFER_DIST,
    output:
        notebook=path.join(NOTEBOOKS_OUTPUT_DIR, SPATIAL_EXTENT_IPYNB_FILENAME),
        spatial_extent=SPATIAL_EXTENT_GPKG,
    shell:
        "papermill {input.notebook} {output.notebook}"
        " -p nominatim_query {params.nominatim_query}"
        " -p buffer_dist {params.buffer_dist}"
        " -p dst_filepath {output.spatial_extent}"


# 2. population grid -------------------------------------------------------------------
POPULATION_GRID_URL = "https://www.idescat.cat/serveis/biblioteca/docs/bib/publicacions/gridpoblacio01012019.zip"
POPULATION_GRID_FILENAME = path.basename(POPULATION_GRID_URL)
POPULATION_GRID_ZIP_FILEPATH = path.join(DATA_RAW_DIR, POPULATION_GRID_FILENAME)
POPULATION_GRID_DIR = path.join(
    DATA_RAW_DIR, path.splitext(POPULATION_GRID_FILENAME)[0]
)
POPULATION_GRID_SHP_FILEPATH = path.join(
    POPULATION_GRID_DIR, "gridpoblacio01012019.shp"
)


# download zip as intermediate target and extract it
rule download_population_grid:
    output:
        temp(POPULATION_GRID_ZIP_FILEPATH),
    shell:
        "wget -O {output} {POPULATION_GRID_URL}"


rule extract_population_grid:
    input:
        POPULATION_GRID_ZIP_FILEPATH,
    output:
        POPULATION_GRID_SHP_FILEPATH,
    shell:
        "unzip -j {input} -d {POPULATION_GRID_DIR} && touch {output}"


# 3. get ndvi ----------------------------------------------------------------
# ORTHOPHOTO_METADATA_ZIP_URL = "https://datacloud.ide.cat/metadades/ortofoto-50cm-v7r0-metadades.zip"
ORTHOPHOTO_METADATA_ZIP_URL = "https://datacloud.ide.cat/metadades/cataleg/ortofoto-50cm-v7r0-2019-metadades-20200720.zip"
ORTHOPHOTO_METADATA_FILENAME = path.basename(ORTHOPHOTO_METADATA_ZIP_URL)
ORTHOPHOTO_METADATA_ZIP_FILEPATH = path.join(DATA_RAW_DIR, ORTHOPHOTO_METADATA_FILENAME)
ORTHOPHOTO_METADATA_DIR = path.join(
    DATA_RAW_DIR, path.splitext(ORTHOPHOTO_METADATA_FILENAME)[0]
)
ORTHOPHOTO_METADATA_SHP_FILEPATH = path.join(
    ORTHOPHOTO_METADATA_DIR, "ortofoto-50cm-v7r0-2019-metadades-20200720.shp"
)


# download zip as intermediate target and extract it
rule download_orthophoto_metadata:
    output:
        temp(ORTHOPHOTO_METADATA_ZIP_FILEPATH),
    shell:
        "wget -O {output} {ORTHOPHOTO_METADATA_ZIP_URL}"


rule extract_orthophoto_metadata:
    input:
        ORTHOPHOTO_METADATA_ZIP_FILEPATH,
    output:
        ORTHOPHOTO_METADATA_SHP_FILEPATH,
    shell:
        "unzip -j {input} -d {ORTHOPHOTO_METADATA_DIR} && touch {output}"


# compute the ndvi raster
NDVI_RASTER_IPYNB_FILENAME = "02-ndvi-raster.ipynb"
NDVI_TIF_FILEPATH = path.join(DATA_PROCESSED_DIR, "ndvi.tif")
STAC_URL = "https://earth-search.aws.element84.com/v0"
STAC_COLLECTION = "sentinel-s2-l2a-cogs"
STAC_EPSG = "4326"
MAX_CLOUD_COVER = 10


rule ndvi_raster:
    input:
        spatial_extent=rules.spatial_extent.output.spatial_extent,
        orthophoto_metadata=rules.extract_orthophoto_metadata.output,
        notebook=path.join(NOTEBOOKS_DIR, NDVI_RASTER_IPYNB_FILENAME),
    params:
        stac_url=STAC_URL,
        stac_collection=STAC_COLLECTION,
        stac_epsg=STAC_EPSG,
        max_cloud_cover=MAX_CLOUD_COVER,  # in percentage
    output:
        notebook=path.join(NOTEBOOKS_OUTPUT_DIR, NDVI_RASTER_IPYNB_FILENAME),
        ndvi=NDVI_TIF_FILEPATH,
    shell:
        "papermill {input.notebook} {output.notebook}"
        " -p spatial_extent_filepath {input.spatial_extent}"
        " -p orthophoto_metadata_filepath {input.orthophoto_metadata}"
        " -p stac_url {params.stac_url}"
        " -p stac_collection {params.stac_collection}"
        " -p stac_epsg {params.stac_epsg}"
        " -p max_cloud_cover {params.max_cloud_cover}"
        " -p dst_filepath {output.ndvi}"
