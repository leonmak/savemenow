import logging

from flask_restful import Resource
from flask import request, abort


logger = logging.getLogger(__name__)
logging_handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging_handler.setFormatter(formatter)
logger.addHandler(logging_handler)


class Hazards(Resource):
    def get(self):
        try:
            geometry = request.json['geometry']
        except KeyError:
            abort(400, "Missing options.")

    def post(self):
        # upsert hazard
        pass


    def delete(self):
        # delete hazard
        pass
