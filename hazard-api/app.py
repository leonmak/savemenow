from flask import Flask
from flask_restful import Api
from resources.hazards import Hazards


app = Flask(__name__)

api = Api(app)

api.add_resource(Hazards, '/hazards')

if __name__ == '__main__':
    app.run(debug=True)