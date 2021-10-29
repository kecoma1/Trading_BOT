from flask import Flask
from flask import render_template, request # Importing request!

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/page_2")
def page_2():
    return render_template("page_2.html")

@app.route("/page_3", methods=["POST"])
def page_3():
    #username = request.form.get("username")
    #username = request.form["username"] # We can access it as a dictionary
    
    #password = request.form["password"] # Error! password is not there
    password = request.form.get("password") # It returns None, not an exception
    #print("The password is:", password)
    
    print("I received the name:", password)
    return render_template("page_3.html")

if __name__ == "__main__":
    app.run(debug=True)