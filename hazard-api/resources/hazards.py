import logging

from flask_restful import Resource
from flask import request, abort
from firebase import firebase

import config

logger = logging.getLogger(__name__)
logging_handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logging_handler.setFormatter(formatter)
logger.addHandler(logging_handler)

firebase_app = firebase.FirebaseApplication(config.FIREBASE_DB, None)
hazards_endpoint = '/hazards'


class Hazards(Resource):
    def get(self):
        result = firebase_app.get(hazards_endpoint)
        logger.info(result)
        return result

    def post(self):
        geometry = ''
        description = ''
        try:
            geometry = request.json['geometry']
            description = request.json['description']
        except KeyError:
            message = 'Key not found'
            logger.error(message)
            abort(400, message)

        hazard = {
            'geometry': geometry,
            'description' : description
        }
        snapshot = firebase_app.post(hazards_endpoint, hazard)
        logger.info('Posted: ', snapshot)
        return {'message': 'Posted hazard with id {}'.format(snapshot['name'])}, 201

    def delete(self):
        # delete hazard by location?
        pass
