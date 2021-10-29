from flask import Flask
from flask import render_template, request, redirect, url_for # Importing redirect and url_for!

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/page_2")
def page_2():
    return render_template("page_2.html")

@app.route("/page_3", methods=["POST"])
def page_3():
    username = request.form.get("username")
    
    print("I received the name:", username)
    return render_template("page_3.html")

@app.route("/EXAMPLE/<arg>")
def example(arg):
    print("The extension in the url is:", arg)
    return render_template("product.html", name=arg.split("_")[1], full_name=arg)

if __name__ == "__main__":
    app.run(debug=True)