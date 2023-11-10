from flask import Flask,request, jsonify, make_response
import mysql.connector
from flask_cors import CORS
import base64


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



# user variables
email = ""
password = ""
username = ""



# -----------------------------------------------------------------------------------------------------
@app.route('/flutter_usernamePP', methods=['POST'])
def set_usernamePP():
    
    # Generate MySQL table if not exists
    create_table_query = """
    CREATE TABLE IF NOT EXISTS profiles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(100) NOT NULL,
        image BLOB,
        image_type VARCHAR(20) DEFAULT 'image/jpeg'
    );
    """
    cursor.execute(create_table_query)
   
    try:
        username = request.form['username']
        image_file = request.files.get('image')
        
        if not image_file:
            return jsonify({'error': 'Image not provided'}), 400

        select_query = 'SELECT username FROM profiles WHERE username = %s'
        cursor.execute(select_query, (username,))
        existing_usernames = cursor.fetchall()

        if len(existing_usernames) >= 1:
                response_data = {'message': 'Username is already taken.', 'status_code': 5}
                response = make_response(jsonify(response_data), 200)
                return response

    
        # Read the binary data of the image
        image_data = image_file.read()

        # Get the MIME type of the image
        image_type = 'image/jpeg'
        #image_type = image_file.mimetype

        cursor.execute("INSERT INTO profiles (username, image, image_type) VALUES (%s, %s, %s)", (username, image_data, image_type))
        db_connection.commit()


        return jsonify({'message': 'Profile uploaded successfully'}), 200
        
        
    except Exception as e:
        print(e)
        return jsonify({'error': 'Error uploading profile'}), 500



# -----------------------------------------------------------------------------------------------------
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
                print("aaaa")
                response_data = {'message': 'Login Successful.', 'status_code': 1}
                response = make_response(jsonify(response_data), 200)
                return response
            else: 
                response_data = {'message': 'Email or password is incorrect.', 'status_code': 2}
                response = make_response(jsonify(response_data), 200)
                return response

        # signup 
        elif _isLoginForm=="false":
            # check whether email is in already database or not
            select_query = 'SELECT email, password FROM users WHERE email = %s'
            cursor.execute(select_query, (email,))
            queries = cursor.fetchall()

            if len(queries) >= 1:
                response_data = {'message': 'You already have an account.', 'status_code': 3}
                response = make_response(jsonify(response_data), 200)
                return response
            else:
                insert_query = 'INSERT INTO users (email, password) VALUES (%s, %s)'
                data = (email, password)
                cursor.execute(insert_query, data)
                db_connection.commit()

                response_data = {'message': 'Sign up is completed.', 'status_code': 4}
                response = make_response(jsonify(response_data), 200)
                return response
            
        return jsonify({'error': 'An error occurred'}), 500
       
    except Exception as e:
        # Handle exceptions and return an error response
        print(f'Error: {e}')
        return jsonify({'error': 'An error occurred'}), 500
    


if __name__ == "__main__":
    app.run()




"""
from flask import send_file

@app.route('/get_image/<int:image_id>')
def get_image(image_id):
    connection = mysql.connect()
    cursor = connection.cursor()

    cursor.execute("SELECT image_data FROM images WHERE id = %s", (image_id,))
    image_data = cursor.fetchone()

    cursor.close()
    connection.close()

    if image_data:
        return send_file(io.BytesIO(image_data[0]), mimetype='image/jpeg')
    else:
        return jsonify({'error': 'Image not found'}), 404

"""