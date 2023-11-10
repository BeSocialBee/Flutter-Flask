from flask import Flask,request, jsonify, make_response
import mysql.connector
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# MySQL database configuration
db_config = {
    'host': 'database-3.ciqpxqolslw4.eu-north-1.rds.amazonaws.com',
    'user': 'master',
    'password': 'masterpassword',
    'database': 'beedatabase',
    'port': 3306,
}
# Create a MySQL connection
db_connection = mysql.connector.connect(**db_config)
cursor = db_connection.cursor()



@app.route('/flutter_auth', methods=['POST'])
def authenticate_user():
    try:
        # Get email and password from the POST request
        email = request.form.get('email')
        password = request.form.get('password')
        _isLoginForm = request.form.get('_isLoginForm')

        # check login 
        if _isLoginForm=="true":
            select_query = 'SELECT email, password FROM users WHERE email = %s and password = %s'
            cursor.execute(select_query, (email,password,))
            queries = cursor.fetchall()

            if len(queries) == 1:
                response_data = {'message': 'Login Successful.', 'status_code': 1}
                response = make_response(jsonify(response_data), 200)
                return response
            else: 
                response_data = {'message': 'Email or password is incorrect.', 'status_code': 2}
                response = make_response(jsonify(response_data), 200)
                return response

        # signup 
        elif _isLoginForm=="false":
            print("signupp")
            # check whether email is in already database or not
            select_query = 'SELECT email, password FROM users WHERE email = %s'
            cursor.execute(select_query, (email,))
            queries = cursor.fetchall()

            if len(queries) >= 1:
                response_data = {'message': 'You already have an account.', 'status_code': 3}
                response = make_response(jsonify(response_data), 200)
                return response
            else: 
                # kullanıcı adı kontrolu yap

                insert_query = 'INSERT INTO users (email, password) VALUES (%s, %s)'
                data = (email, password)
                cursor.execute(insert_query, data)
                db_connection.commit()

                response_data = {'message': 'Sign up is completed.', 'status_code': 4}
                response = make_response(jsonify(response_data), 200)
                return response


    

        """
        select_query = 'SELECT * FROM users'
        cursor.execute(select_query)
        articles = cursor.fetchall()
        for x in articles:
            print(x)
        """
            
        return jsonify({'error': 'An error occurred'}), 500
       
    except Exception as e:
        # Handle exceptions and return an error response
        print(f'Error: {e}')
        return jsonify({'error': 'An error occurred'}), 500
    


if __name__ == "__main__":
    app.run()