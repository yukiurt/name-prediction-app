#!/usr/bin/env python3

import os
from flask import Flask, jsonify, request

import json
from prediction import predict, extract_name_features


HEADERS = {'Content-type': 'application/json', 'Accept': 'text/plain'}

def flask_app():
    app = Flask(__name__)


    @app.route('/', methods=['GET'])
    def server_is_up():
        # print("success")
        return 'server is up - Yay! \n \n'

    @app.route('/predict', methods=['POST'])
    def start():
        to_predict = request.json
        mode = to_predict.get("mode")
        name = to_predict.get("name")

        if not name or not mode:
            return jsonify({"error": "Please provide a name and mode"}), 400

        try:
            pred = predict(name, mode=mode)

            if mode == "birth_month":
                return jsonify({"predicted_birth_month": pred})
            elif mode == "sex":
                return jsonify({"predicted_sex": pred})
            elif mode == "subject":
                return jsonify({"predicted_subject": pred})
            elif mode == "age":
                return jsonify({"predicted_age": pred})
            else:
                return jsonify({"error": "Invalid mode"}), 400

        except Exception as e:
            return jsonify({"error": str(e)}), 500

    return app

if __name__ == '__main__':
    app = flask_app()
    app.run(debug=True, host='0.0.0.0',port=5001)


